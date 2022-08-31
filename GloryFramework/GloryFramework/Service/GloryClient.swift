//
//  SoapClient.swift
//  GlorySDK
//
//  Created by John Kricorian on 06/07/2021.
//

import UIKit

protocol GloryClientDelegate: AnyObject {
    func openSession(user: String, completionHandler: @escaping OpenUseCase)
    func occupy(sessionId: String, completionHandler: OccupyUseCase)
    func inventory(sessionId: String, completionHandler: InventoryUseCase)
    func unregisterEvents(sessionId: String, eventServerIp: String, eventServerPort: String, completionHandler: UnRegisterEventUseCase)
    func registerEvents(sessionId: String, eventServerIp: String, eventServerPort: String, registerEventHandler: RegisterEventUseCase)
    func adjustTime(sessionId: String, completionHandler: AdjustTimeStatusUseCase)
    func releaseMachine(sessionId: String, completionHandler: OccupyUseCase)
    func closeSession(sessionId: String, completionHandler: OccupyUseCase)
    func getStatus(sessionId: String, completionHandler: @escaping GetStatusUseCase)
    func change(sessionId: String, amount: Int, transaction: Transaction, completionHandler: @escaping ChangeRequestHandler)
    func changeCancel(sessionId: String, completionHandler: ChangeCancelUseCase)
    func reset(sessionId: String, completionHandler: OccupyUseCase)
    func openCoverExit(sessionId: String, coverHandler: CoverUseCase)
    func closeCoverExit(sessionId: String, coverHandler: CoverUseCase)
}

class GloryClient {
    
    // MARK: - Private Properties
    private let url: URL
    private let id: String = UIDevice.current.identifierForVendor?.uuidString ?? "id"
    private var logger: GloryLoggerDelegate
    private var gloryOutputDelegate: GloryOutputDelegate
    private var dataParser: DataParserProtocol
    
    internal init(serverIp: String, logger: GloryLoggerDelegate, gloryOutputDelegate: GloryOutputDelegate) {
        self.url = URL(string: "http://\(serverIp)/axis2/services/BrueBoxService")!
        self.logger = logger
        self.gloryOutputDelegate = gloryOutputDelegate
        self.dataParser = DataParser()
    }
}

// MARK: - Private Methods
private extension GloryClient {
    
    func loadData(data: Data?, response: URLResponse?, error: Error?, responseTag: String, completionHandler: @escaping GetNodesUseCase) {
        if let error = error {
            completionHandler(.failure(error))
            return;
        }
        
        guard let httpUrlResponse = response as? HTTPURLResponse else {
            completionHandler(.failure(HttpUrlResponseError(error: error, response: response)))
            return
        }

        let successRange = 200...299
        if successRange.contains(httpUrlResponse.statusCode) {
            parse(data: data, responseTag: responseTag, completionHandler: completionHandler)
        } else {
            completionHandler(.failure(ApiError(data: data, httpUrlResponse: httpUrlResponse)))
        }
    }
    
    func parse(data: Data?, responseTag: String, completionHandler: @escaping GetNodesUseCase) {
        guard let data = data else {
            completionHandler(.failure(XMLParseError(data: data)))
            return
        }
        let body = MicroDOM(data: data).parse()?.getElementsByTagName(TagName.soapenvBody()).first
        
        guard let elements = body?.getElementsByTagName(responseTag) else {
            completionHandler(.failure(XMLParseError(data: data)))
            return
        }
        if let rawValue = body?.childNodes.first?.getAttribute("n:result") {
            if responseTag != "n:RegisterEventResponse",
                let responseResult = ResponseResult(rawValue: rawValue) {
                if responseResult == .success || responseResult == .occupiedByItself || responseResult == .invalidSession || responseResult == .cancel || responseResult == .occupiedByOther {
                    completionHandler(.success(elements))
                } else if responseResult == .exclusiveError {
                    let exclusiveError = ExclusiveError(responseResult: responseResult, message: responseResult.rawValue)
                    completionHandler(.failure(exclusiveError))
                } else {
                    let otherError = OtherError(responseResult: responseResult, message: responseResult.rawValue)
                    completionHandler(.failure(otherError))
                }
            } else {
                if let serverStatusResponse = ServerStatusResponse(rawValue: rawValue) {
                    if serverStatusResponse == .success {
                        completionHandler(.success(elements))
                    } else {
                        let statusResponseError = StatusResponseError(serverStatusResponse: serverStatusResponse)
                        completionHandler(.failure(statusResponseError))
                    }
                }
                else {
                    completionHandler(.failure(FormatError()))
                }
            }
        } else {
            completionHandler(.failure(FormatError()))
        }
    }
    
    func createRequest(operation: Operation, body: String) -> URLRequest {
        let seqNo = increaseSequenceNumber()
        var request = URLRequest(url: url, cachePolicy: .reloadIgnoringCacheData, timeoutInterval: 3600)
        request.httpMethod = "POST"
        request.allHTTPHeaderFields = ["content-type": "text/xml"]
        request.allHTTPHeaderFields?.updateValue(operation.operationName, forKey: "SOAPAction")
        let httpBody = "<soapenv:Envelope xmlns:soapenv=\"http://schemas.xmlsoap.org/soap/envelope/\" xmlns:bru=\"http://www.glory.co.jp/bruebox.xsd\"><soapenv:Header/><soapenv:Body><bru:\(operation.requestName)><!--Optional:--><bru:Id>\(id)</bru:Id><bru:SeqNo>\(seqNo)</bru:SeqNo>" + "\(body)" + "</bru:\(operation.requestName)></soapenv:Body></soapenv:Envelope>"
        request.httpBody = httpBody.data(using: .utf8)
        return request
    }
    
    func increaseSequenceNumber() -> Int {
        let userSettings = UserSettings.shared()
        guard let diff = Calendar.current.dateComponents([.day], from: userSettings.lastRefreshDate, to: Date()).day,
              let currentHour = Calendar.current.dateComponents([.hour], from: Date()).hour else { return 0 }
        if diff >= 1, 0 <= currentHour {
            userSettings.seqNo = 0
        } else {
            userSettings.seqNo += 1
        }
        userSettings.lastRefreshDate = Date()
        return userSettings.seqNo
    }
    
    func executeSoapRequest(operation: Operation, body: String, completionHandler: @escaping GetNodesUseCase) {
        let request = createRequest(operation: operation, body: body)
        let dataTask = URLSession.shared.dataTask(with: request) { (data, response, error) in
            DispatchQueue.main.async {
                self.loadData(data: data, response: response, error: error, responseTag: operation.responseTag) { result in
                    switch result {
                    case .success(_):
                        self.logger.info(message: "Soap Operation: \(operation.requestName)", meta: ["output": response ?? ""])
                    case .failure(let error):
                        let err = error as NSError
                        let code = err.code
                        let description = err.description
                        self.logger.error(message: "Soap Operation: \(operation.requestName) - \(description)", meta: ["error": error.localizedDescription,
                                                                                                                       "description": description,
                                                                                                                       "code": code,
                                                                                                                       "input": body,
                                                                                                                       "output": response ?? ""])
                    }
                    completionHandler (result)
                }
            }
        }
        dataTask.resume()
    }
    
    func createOperation(operation: Operation, sessionId: String, completionHandler: OccupyUseCase = nil, coverHandler: CoverUseCase = nil) {
        let body = "<!--Optional:--><bru:SessionID>\(sessionId)</bru:SessionID>"
        executeSoapRequest(operation: operation, body: body) { result in
            switch result {
            case .success(let response):
                let rawValue = self.dataParser.getRawValue(response: response)
                guard let occupyStatus = OccupyStatus(rawValue: rawValue) else { return }
                completionHandler?(.success(occupyStatus))
            case .failure(let error):
                completionHandler?(.failure(error))
            }
        }
    }
}

extension GloryClient: GloryClientDelegate {

    func occupy(sessionId: String, completionHandler: OccupyUseCase) {
        createOperation(operation: .occupy,
                      sessionId: sessionId,
                      completionHandler: completionHandler)
    }
    
    func releaseMachine(sessionId: String, completionHandler: OccupyUseCase) {
        createOperation(operation: .release,
                      sessionId: sessionId,
                      completionHandler: completionHandler)
    }
    
    func closeSession(sessionId: String, completionHandler: OccupyUseCase) {
        createOperation(operation: .close,
                      sessionId: sessionId,
                      completionHandler: completionHandler)
    }
    
    func reset(sessionId: String, completionHandler: OccupyUseCase) {
        createOperation(operation: .reset,
                      sessionId: sessionId,
                      completionHandler: completionHandler)
    }
    
    func closeCoverExit(sessionId: String, coverHandler: CoverUseCase) {
        let body = "<!--Optional:--><bru:SessionID>\(sessionId)</bru:SessionID>"
        executeSoapRequest(operation: .closeCoverExit, body: body) { result in
            switch result {
            case .success(let response):
                let rawValue = self.dataParser.getRawValue(response: response)
                guard let coverStatus = CoverStatus(rawValue: rawValue) else { return }
                coverHandler?(.success(coverStatus))
            case .failure(let error):
                coverHandler?(.failure(error))
            }
        }
    }
    
    func openCoverExit(sessionId: String, coverHandler: CoverUseCase) {
        let body = "<!--Optional:--><bru:SessionID>\(sessionId)</bru:SessionID>"
        executeSoapRequest(operation: .openCoverExit, body: body) { result in
            switch result {
            case .success(let response):
                let rawValue = self.dataParser.getRawValue(response: response)
                guard let coverStatus = CoverStatus(rawValue: rawValue) else { return }
                coverHandler?(.success(coverStatus))
            case .failure(let error):
                coverHandler?(.failure(error))
            }
        }
    }
    
    func openSession(user: String, completionHandler: @escaping OpenUseCase) {
        let body = "<bru:User>\(user)</bru:User><bru:UserPwd></bru:UserPwd><bru:DeviceName>?</bru:DeviceName>"
        executeSoapRequest(operation: .open, body: body) { result in
            switch result {
            case .success(let nodes):
                guard let node = nodes.first?.childNodes[3] else { return }
                completionHandler(.success(node.data))
            case .failure(let error):
                completionHandler(.failure(error))
            }
        }
    }
        
    func inventory(sessionId: String, completionHandler: InventoryUseCase) {
        let body = "<!--Optional:--><bru:SessionID>\(sessionId)</bru:SessionID><!--Optional:--><Option bru:type=\"2\">"
        executeSoapRequest(operation: .inventory, body: body) { result in
            switch result {
            case .success(let childNodes):
                let moneyItems = self.dataParser.parseMoneyItems(childNodes.first, attributePrefix: "n:")
                completionHandler?(.success(moneyItems))
            case .failure(let error):
                completionHandler?(.failure(error))
            }
        }
    }
    
    func unregisterEvents(sessionId: String, eventServerIp: String, eventServerPort: String, completionHandler: UnRegisterEventUseCase) {
        let body = "<!--Optional:--><bru:SessionID>\(sessionId)</bru:SessionID><bru:Url>\(eventServerIp)</bru:Url><!--Optional:--><bru:Port>\(eventServerPort)</bru:Port>"
        executeSoapRequest(operation: .unregisterEvent, body: body) { result in
            switch result {
            case .success(let response):
                let rawValue = self.dataParser.getRawValue(response: response)
                guard let unRegisterEventStatus = UnRegisterEventStatus(rawValue: rawValue) else { return }
                if unRegisterEventStatus == .success || unRegisterEventStatus == .notYetRegister {
                    completionHandler?(.success(unRegisterEventStatus))
                } else {
                    completionHandler?(.failure(UnRegisterEventError(unRegisterEventStatus: unRegisterEventStatus)))
                }
            case .failure(let error):
                completionHandler?(.failure(error))
            }
        }
    }
    
    func registerEvents(sessionId: String, eventServerIp: String, eventServerPort: String, registerEventHandler: RegisterEventUseCase) {
        let body = "<!--Optional:--><bru:SessionID>\(sessionId)</bru:SessionID><bru:Url>\(eventServerIp)</bru:Url><!--Optional:--><bru:Port>\(eventServerPort)</bru:Port><!--Optional:--><DestinationType bru:type=\"0\"/><!--Optional:--><Encryption bru:type=\"?\"/><!--Optional:--><RequireEventList></RequireEventList>"
        executeSoapRequest(operation: .registerEvent, body: body) { result in
            switch result {
            case .success(let response):
                let rawValue = self.dataParser.getRawValue(response: response)
                guard let statusResponse = ServerStatusResponse(rawValue: rawValue) else { return }
                if statusResponse == .success {
                    registerEventHandler?(.success(statusResponse))
                } else {
                    registerEventHandler?(.failure(RegisterEventError(serverStatusResponse: statusResponse)))
                }
            case .failure(let error):
                registerEventHandler?(.failure(error))
            }
        }
    }
    
    func adjustTime(sessionId: String, completionHandler: AdjustTimeStatusUseCase) {
        let calendar = CalendarComponents()
        let body = "<!--Optional:--><bru:SessionID>\(sessionId)</bru:SessionID><Date bru:month=\"\(calendar.month)\" bru:day=\"\(calendar.day)\" bru:year=\"\(calendar.year)\"/><Time bru:hour=\"\(calendar.hour)\" bru:minute=\"\(calendar.minute)\" bru:second=\"\(calendar.second)\"/>"
        executeSoapRequest(operation: .adjustTime, body: body) { result in
            switch result {
            case .success(let response):
                let rawValue = self.dataParser.getRawValue(response: response)
                guard let adjustTimeStatus = AdjustTimeStatus(rawValue: rawValue) else { return }
                completionHandler?(.success(adjustTimeStatus))
            case .failure(let error):
                completionHandler?(.failure(error))
            }
        }
    }
    
    func getStatus(sessionId: String, completionHandler: @escaping GetStatusUseCase) {
        let body = "<!--Optional:--><bru:SessionID>\(sessionId)</bru:SessionID><Option bru:type=\"?\"/><!--Optional:--><RequireVerification bru:type=\"1\"/>"
        executeSoapRequest(operation: .status, body: body) { result in
            switch result {
            case .success(let nodes):
                self.dataParser.didUpdateStatus(node: nodes.first) { statusCode, coinDevStatus, billDevStatus, error in
                    let machineStatus = MachineStatus(statusCode: statusCode, billDevStatus: billDevStatus, coinDevStatus: coinDevStatus)
                    completionHandler(.success(machineStatus))
                }
            case .failure(let error):
                completionHandler(.failure(error))
            }
        }
    }
        
    func change(sessionId: String, amount: Int, transaction: Transaction, completionHandler: @escaping ChangeRequestHandler) {
        let body = "<!--Optional:--><bru:SessionID>\(sessionId)</bru:SessionID><bru:Amount>\(amount)</bru:Amount><!--Optional:--><Option bru:type=\"?\"/><!--Optional:--><Cash bru:type=\"?\" bru:note_destination=\"?\" bru:coin_destination=\"?\"><!--Zero or more repetitions:--><Denomination bru:cc=\"?\" bru:fv=\"?\" bru:rev=\"?\" bru:devid=\"?\"><bru:Piece>?</bru:Piece><bru:Status>?</bru:Status></Denomination></Cash><!--Optional:--><!--<ForeignCurrency bru:cc=\"?\"><Rate>?</Rate></ForeignCurrency>-->"
        executeSoapRequest(operation: .change, body: body) { result in
            switch result {
            case .success(let nodes):
                self.dataParser.parseTransaction(nodes: nodes, transaction: transaction)
                
                guard let rawValue = nodes.first?.getAttribute("n:result"),
                      let responseResult = ResponseResult(rawValue: rawValue)
                else {
                    completionHandler(.failure(FormatError()))
                    return
                }
                if responseResult != .success && responseResult != .cancel && responseResult != .cancelChangeShortage {
                    completionHandler(.failure(FormatError()))
                    return
                }
                
                completionHandler(.success(transaction))
            case .failure(let error):
                completionHandler(.failure(error))
            }
        }
    }
    
    func changeCancel(sessionId: String, completionHandler: ChangeCancelUseCase) {
        let body = "<!--Optional:--><bru:SessionID>\(sessionId)</bru:SessionID><!--Optional:--><Option bru:type=\"?\">"
        executeSoapRequest(operation: .changeCancel, body: body) { result in
            switch result {
            case .success(_):
                completionHandler?(.success(.success))
            case .failure(let error):
                completionHandler?(.failure(error))
            }
        }
    }
}
