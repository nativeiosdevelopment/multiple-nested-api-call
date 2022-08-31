import Foundation
import Network

protocol GloryEventServerDelegate: AnyObject {
    func didReceiveData(_ data: Data)
    func serverDidFail()
}

internal class GloryEventServer {

    // MARK: - Internal Properties
    internal var eventServerDelegate: GloryEventServerDelegate

    // MARK: - Private Properties
    private var listener: NWListener?
    private var connection: NWConnection?
    private let MTU = 65536
    private var receivedData = Data()
    private var didStopCallback: ((Error?) -> Void)? = nil
    private let logger: GloryLoggerDelegate
    
    internal init(logger: GloryLoggerDelegate, eventServerDelegate: GloryEventServerDelegate) {
        self.eventServerDelegate = eventServerDelegate
        self.logger = logger
    }
    
    internal func start(port: UInt16) {
        let listener = try! NWListener(using: .tcp, on: NWEndpoint.Port(rawValue: port)!)
        listener.stateUpdateHandler = self.stateDidChange(to:)
        listener.newConnectionHandler = self.didAccept(nwConnection:)
        listener.start(queue: .main)
        self.listener = listener
    }
    
    internal func stopConnection() {
        listener?.stateUpdateHandler = nil
        listener?.newConnectionHandler = nil
        listener?.cancel()
        listener = nil
        connectionDidEnd()
    }
    
    private func connectionDidEnd() {
        stop(error: nil)
    }
    
    private func stateDidChange(to newState: NWListener.State) {
        switch newState {
        case .ready:
            logger.info(message: "Server ready.", meta: nil)
        case .cancelled:
            eventServerDelegate.serverDidFail()
            logger.info(message: "Cancelled", meta: nil)
        case .failed(let error):
            eventServerDelegate.serverDidFail()
            logger.error(message: "Server failure: \(error.localizedDescription)", meta: nil)
        default:
            break
        }
    }
    
    private func didAccept(nwConnection: NWConnection) {
        connection = nwConnection
        connection?.start(queue: .main)
        setupReceive()
    }
    
    private func setupReceive() {
        connection?.receive(minimumIncompleteLength: 1, maximumLength: MTU) { (data, _, isComplete, error) in
            if let data = data, !data.isEmpty {
                self.receivedData.append(data)
                self.processData()
            }
            if isComplete {
                self.connectionDidEnd()
            } else if let error = error {
                self.connectionDidFail(error: error)
            } else {
                self.setupReceive()
            }
        }
    }
    
    private func processData() {
        while let index = receivedData.firstIndex(of: 0) {
            eventServerDelegate.didReceiveData(receivedData.prefix(upTo: index))
            receivedData.removeSubrange(0...index)
        }
    }
        
    private func connectionDidFail(error: Error) {
        stop(error: error)
    }
    
    private func stop(error: Error?) {
        connection?.stateUpdateHandler = nil
        connection?.cancel()
        if let didStopCallback = didStopCallback {
            self.didStopCallback = nil
            didStopCallback(error)
        }
    }
}


