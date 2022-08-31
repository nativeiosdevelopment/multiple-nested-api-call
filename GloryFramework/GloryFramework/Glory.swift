//
//  Interactor.swift
//  GloryFramework
//
//  Created by John Kricorian on 30/07/2021.
//

import Foundation

public protocol GloryOutputDelegate: AnyObject {
    func didUpdate(emptyMoneyItems: [MoneyItem])
    func didUpdateConnexion(isConnected: Bool)
    func didUpdateStacker(isFlagged: Bool)
    func didUpdate(statusCode: StatusCode)
    func didUpdate(billDevStatus: DeviceStatus)
    func didUpdate(coinDevStatus: DeviceStatus)
    func didStart(transaction: Transaction?)
    func didUpdate(transaction: Transaction?)
    func didSucceed(transaction: Transaction?)
    func didFail(transaction: Transaction?, error: Error)
    func didUpdateEventError(url: String, errorCode: Int)
    func connectionDidFail(error: Error)
    func serverDidFail()
}

public class Glory {
    
    // MARK: - Public Properties
    public var currentTransaction: Transaction?
    
    // MARK: - Private Properties
    private var client: GloryClient?
    private var user: String = ""
    private var gloryOutputDelegate: GloryOutputDelegate?
    private var logger: GloryLoggerDelegate?
    private var eventServer: GloryEventServer?
    private var userSettings = UserSettings.shared()
    private var timer: Timer?
    private var lastReceivedMessage: Date?
    private var eventsHandler: EventsHandlerProtocol?
    
    public init() {}
    
    // MARK: - Public Methods
    public func connect(gloryOutputDelegate: GloryOutputDelegate, logger: GloryLoggerDelegate, serverIp: String, user: String) {
        self.gloryOutputDelegate = gloryOutputDelegate
        self.eventsHandler = EventsHandler(gloryOutputDelegate: gloryOutputDelegate, logger: logger)
        self.user = user
        self.logger = logger
        self.eventServer = GloryEventServer(logger: logger, eventServerDelegate: self)
        client = GloryClient(serverIp: serverIp, logger: logger, gloryOutputDelegate: gloryOutputDelegate)
        openSession() { result in
            switch result {
            case .success(let sessionId):
                self.client?.occupy(sessionId: sessionId) { result in
                    switch result {
                    case .success(let occupyStatus):
                        if occupyStatus == .success || occupyStatus == .occupiedByItself {
                            self.client?.inventory(sessionId: sessionId) { result in
                                switch result {
                                case .success(let moneyItems):
                                    gloryOutputDelegate.didUpdate(emptyMoneyItems: moneyItems)
                                    self.startServer(sessionId: sessionId) { result in
                                        switch result {
                                        case .success:
                                            self.client?.adjustTime(sessionId: sessionId) { result in
                                                switch result {
                                                case .success(let adjustTimeStatus):
                                                    if adjustTimeStatus == .success {
                                                        self.client?.releaseMachine(sessionId: sessionId) { result in
                                                            switch result {
                                                            case .success(let occupyStatus):
                                                                if occupyStatus == .success || occupyStatus == .occupiedByItself {
                                                                    self.client?.closeSession(sessionId: sessionId) { result in
                                                                        switch result {
                                                                        case .success(let occupyStatus):
                                                                            if occupyStatus == .success || occupyStatus == .occupiedByItself {
                                                                                self.client?.getStatus(sessionId: sessionId) { result in
                                                                                    switch result {
                                                                                    case .success(let machineStatusCode):
                                                                                        if let statusCode = machineStatusCode.statusCode,
                                                                                           let coinDevStatus = machineStatusCode.coinDevStatus,
                                                                                           let billDevStatus = machineStatusCode.billDevStatus {
                                                                                            gloryOutputDelegate.didUpdate(statusCode: statusCode)
                                                                                            gloryOutputDelegate.didUpdate(coinDevStatus: coinDevStatus)
                                                                                            gloryOutputDelegate.didUpdate(billDevStatus: billDevStatus)
                                                                                        }
                                                                                    case .failure(let error):
                                                                                        gloryOutputDelegate.connectionDidFail(error: error)
                                                                                    }
                                                                                }
                                                                            } else {
                                                                                gloryOutputDelegate.connectionDidFail(error: OccupyStatusError(occupyStatus: occupyStatus))
                                                                            }
                                                                        case .failure(let error):
                                                                            gloryOutputDelegate.connectionDidFail(error: error)
                                                                        }
                                                                    }
                                                                } else {
                                                                    gloryOutputDelegate.connectionDidFail(error: ReleaseError(occupyStatus: occupyStatus))
                                                                }
                                                            case .failure(let error):
                                                                gloryOutputDelegate.connectionDidFail(error: error)
                                                            }
                                                        }
                                                    } else {
                                                        gloryOutputDelegate.connectionDidFail(error: AdjustTimeError(adjustTimeStatus: adjustTimeStatus))
                                                    }
                                                case .failure(let error):
                                                    gloryOutputDelegate.connectionDidFail(error: error)
                                                }
                                            }
                                            
                                        case .failure(let error):
                                            gloryOutputDelegate.connectionDidFail(error: error)
                                        }
                                    }
                                case .failure(let error):
                                    gloryOutputDelegate.connectionDidFail(error: error)
                                }
                            }
                        } else {
                            gloryOutputDelegate.connectionDidFail(error: OccupyStatusError(occupyStatus: occupyStatus))
                        }
                    case .failure(let error):
                        gloryOutputDelegate.connectionDidFail(error: error)
                    }
                }
            case .failure(let error):
                gloryOutputDelegate.connectionDidFail(error: error)
            }
        }
    }
    
    public func occupy(completionHandler: OccupyUseCase = nil) {
        client?.openSession(user: user) { result in
            switch result {
            case .success(let sessionId):
                self.client?.occupy(sessionId: sessionId, completionHandler: completionHandler)
            case .failure(let error):
                completionHandler?(.failure(error))
            }
        }
    }
    
    public func change(amount: Int, gloryOutputDelegate: GloryOutputDelegate, completionHandler: @escaping ChangeUseCase) {
        let transaction = makeCurrentTransaction(amount: amount)
        gloryOutputDelegate.didStart(transaction: currentTransaction)
        self.client?.openSession(user: self.user) { result in
            switch result {
            case .success(let sessionId):
                self.client?.getStatus(sessionId: sessionId) { result in
                    switch result {
                    case .success(let machineStatus):
                        if let statusCode = machineStatus.statusCode {
                            if statusCode == .idle || statusCode == .counting || statusCode == .unlocking || statusCode == .waitingRemovalOfCOFT {
                                self.client?.occupy(sessionId: sessionId) { result in
                                    switch result {
                                    case .success(let occupyStatus):
                                        if occupyStatus != .success && occupyStatus != .occupiedByItself {
                                            gloryOutputDelegate.didFail(transaction: self.currentTransaction, error: OccupyStatusError(occupyStatus: occupyStatus))
                                        } else {
                                            self.client?.change(sessionId: sessionId, amount: amount, transaction: transaction, completionHandler: { result in
                                                switch result {
                                                case .success(let transaction):
                                                    self.gloryOutputDelegate?.didSucceed(transaction: transaction)
                                                    self.currentTransaction = nil
                                                case .failure(let error):
                                                    self.gloryOutputDelegate?.didFail(transaction: transaction, error: error)
                                                }
                                                self.releaseAndClose(sessionId: sessionId)
                                            })
                                        }
                                    case .failure(let error):
                                        gloryOutputDelegate.didFail(transaction: transaction, error: error)
                                    }
                                }
                            } else {
                                let error = ExclusiveError(responseResult: nil, message: nil)
                                gloryOutputDelegate.didFail(transaction: self.currentTransaction, error: error)
                            }
                        }
                    case .failure(let error):
                        gloryOutputDelegate.didFail(transaction: self.currentTransaction, error: error)
                    }
                }
            case .failure(let error):
                gloryOutputDelegate.didFail(transaction: self.currentTransaction, error: error)
            }
        }
    }
    
    public func changeCancel(completionHandler: ChangeCancelUseCase = nil) {
        self.client?.openSession(user: user) { result in
            switch result {
            case .success(let sessionId):
                self.client?.occupy(sessionId: sessionId) { result in
                    switch result {
                    case .success(let occupyStatus):
                        if occupyStatus != .success && occupyStatus != .occupiedByItself {
                            self.gloryOutputDelegate?.didFail(transaction: self.currentTransaction, error: OccupyStatusError(occupyStatus: occupyStatus))
                        } else {
                            self.client?.openSession(user: self.user) { result in
                                switch result {
                                case .success(let sessionId):
                                    self.client?.changeCancel(sessionId: sessionId) { result in
                                        switch result {
                                        case .success(let changeCancelStatus):
                                            if changeCancelStatus == .success {
                                                self.releaseAndClose(sessionId: sessionId) { success in
                                                    completionHandler?(.success(.success))
                                                }
                                            }
                                        case .failure(let error):
                                            completionHandler?(.failure(error))
                                        }
                                    }
                                case .failure(let error):
                                    completionHandler?(.failure(error))
                                }
                            }
                        }
                    case .failure(let error):
                        completionHandler?(.failure(error))
                    }
                }
            case .failure(let error):
                completionHandler?(.failure(error))
            }
        }
    }
    
    public func reset(completionHandler: OccupyUseCase = nil) {
        client?.openSession(user: user) { result in
            switch result {
            case .success(let sessionId):
                self.client?.reset(sessionId: sessionId, completionHandler: completionHandler)
            case .failure(let error):
                completionHandler?(.failure(error))
            }
        }
    }
    
    public func startServer(completionHandler: StartServerUseCase) {
        client?.openSession(user: user) { result in
            switch result {
            case .success(let sessionId):
                self.startServer(sessionId: sessionId, completionHandler: completionHandler)
            case .failure(let error):
                completionHandler?(.failure(error))
            }
        }
    }
    
    public func unregisterEvents(completionHandler: UnRegisterEventUseCase = nil) {
        client?.openSession(user: user) { result in
            switch result {
            case .success(let sessionId):
                self.unregisterEvents(sessionId: sessionId, completionHandler: completionHandler)
            case .failure(let error):
                completionHandler?(.failure(error))
            }
        }
    }
    
    public func releaseMachine(completionHandler: OccupyUseCase = nil) {
        client?.openSession(user: user) { result in
            switch result {
            case .success(let sessionId):
                self.client?.releaseMachine(sessionId: sessionId, completionHandler: completionHandler)
            case .failure(let error):
                completionHandler?(.failure(error))
            }
        }
    }
    
    public func openCoverExit(completionHandler: CoverUseCase = nil) {
        client?.openSession(user: user) { result in
            switch result {
            case .success(let sessionId):
                self.client?.openCoverExit(sessionId: sessionId, coverHandler: completionHandler)
            case .failure(let error):
                completionHandler?(.failure(error))
            }
        }
    }
    
    public func closeCoverExit(completionHandler: CoverUseCase = nil) {
        client?.openSession(user: user) { result in
            switch result {
            case .success(let sessionId):
                self.client?.closeCoverExit(sessionId: sessionId, coverHandler: completionHandler)
            case .failure(let error):
                completionHandler?(.failure(error))
            }
        }
    }
    
    public func disconnect() {
        eventServer?.stopConnection()
        unregisterEvents() { _ in
            self.client = nil
        }
        gloryOutputDelegate?.didUpdateConnexion(isConnected: false)
        eventsHandler = nil
        eventServer = nil
        timer?.invalidate()
        timer = nil
    }
    
    // MARK: - Private Methods
    
    private func saveEventServerEndpoint(eventServerIp: String, eventServerPort: String) {
        userSettings.host.updateValue(eventServerIp, forKey: "eventServerIp")
        userSettings.host.updateValue(eventServerPort, forKey: "eventServerPort")
    }
    
    private func startServer(port: UInt16, startServerHandler: StartServerUseCase = nil) {
        eventServer?.start(port: port)
    }
    
    private func unregisterEvents(sessionId: String, completionHandler: UnRegisterEventUseCase) {
        if let eventServerIp = userSettings.host["eventServerIp"], eventServerIp != "", let eventServerPort = userSettings.host["eventServerPort"], eventServerPort != "" {
            self.client?.unregisterEvents(sessionId: sessionId, eventServerIp: eventServerIp, eventServerPort: eventServerPort, completionHandler: completionHandler)
        } else {
            completionHandler?(.success(.notYetRegister))
        }
    }
    
    private func startServer(sessionId: String, completionHandler: StartServerUseCase) {
        self.unregisterEvents(sessionId: sessionId) { result in
            switch result {
                case .success:
                    let serverEventIp = UIDevice.current.ipAddress
                    let serverEventPort = Int.random(in: 10000..<12000)
                    self.startServer(port: UInt16(serverEventPort))
                    self.client?.registerEvents(sessionId: sessionId, eventServerIp: serverEventIp, eventServerPort: String(serverEventPort), registerEventHandler: { result in
                        switch result {
                            case .success:
                                self.saveEventServerEndpoint(eventServerIp: serverEventIp, eventServerPort: String(serverEventPort))
                                completionHandler?(.success(true))
                            case .failure(let error):
                                completionHandler?(.failure(error))
                        }
                    })
                case .failure(let error):
                    completionHandler?(.failure(error))
            }
        }
    }
}

internal extension Glory {
    func openSession(completionHandler: @escaping OpenUseCase) {
        client?.openSession(user: user, completionHandler: completionHandler)
    }
}

private extension Glory {
    
    func releaseAndClose(sessionId: String, completionHandler: ReleaseAndCloseUseCase = nil) {
        client?.releaseMachine(sessionId: sessionId) { _ in
            self.client?.closeSession(sessionId: sessionId) { _ in
                self.currentTransaction = nil
                completionHandler?(true)
            }
        }
    }
    
    func makeCurrentTransaction(amount: Int) -> Transaction {
        let transaction = Transaction(amount: amount, manualDeposite: 0, insertedCash: [], sentBackCash: [])
        currentTransaction = transaction
        eventsHandler?.setCurrentTransaction(transaction: transaction)
        return transaction
    }
}

// MARK: - ServerDelegate
extension Glory: GloryEventServerDelegate {
    
    func serverDidFail() {
        gloryOutputDelegate?.serverDidFail()
        gloryOutputDelegate?.didUpdateConnexion(isConnected: false)
        timer?.invalidate()
    }
    
    func didReceiveData(_ data: Data) {
        if !data.isEmpty {
            gloryOutputDelegate?.didUpdateConnexion(isConnected: true)
            lastReceivedMessage = Date()
            timer = Timer.scheduledTimer(timeInterval: 20, target: self, selector: #selector(updateConnectedStatus), userInfo: nil, repeats: true)
            eventsHandler?.handleNewEvent(data: data)
        }
    }
    
    @objc
    func updateConnectedStatus() {
        guard let lastReceivedMessage = lastReceivedMessage, let dateAddedByThirtySeconds = Calendar.current.date(byAdding: .second, value: +30, to: lastReceivedMessage) else { return }
        gloryOutputDelegate?.didUpdateConnexion(isConnected: Date() < dateAddedByThirtySeconds)
    }
}


