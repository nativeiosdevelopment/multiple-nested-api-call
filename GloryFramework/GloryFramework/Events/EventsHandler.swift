//
//  EventsHandler.swift
//  GloryFramework
//
//  Created by John Kricorian on 25/01/2022.
//

import Foundation

protocol EventsHandlerProtocol: AnyObject {
    func handleNewEvent(data: Data)
    func setCurrentTransaction(transaction: Transaction)
}

class EventsHandler {
        
    // MARK: - Internal Properties
    internal var currentTransaction: Transaction?
    
    // MARK: - Private Properties
    private var gloryOutputDelegate: GloryOutputDelegate
    private var dataParser: DataParserProtocol
    private var logger: GloryLoggerDelegate
    
    internal init(gloryOutputDelegate: GloryOutputDelegate, logger: GloryLoggerDelegate) {
        self.gloryOutputDelegate = gloryOutputDelegate
        self.dataParser = DataParser()
        self.logger = logger
    }
}

// MARK: - EventsHandlerProtocol
extension EventsHandler: EventsHandlerProtocol {
    internal func setCurrentTransaction(transaction: Transaction) {
        self.currentTransaction = transaction
    }
    
    internal func handleNewEvent(data: Data) {
        if let node = MicroDOM(data: data).parse() {
            guard !node.childNodes[0].childNodes.isEmpty,
                  let rawValue = node.childNodes[safe:0]?.tag,
                  let event = Event(rawValue: rawValue) else { return }
            logger.info(message: "Event: \(rawValue)", meta: ["input": String(data: data, encoding: .utf8) ?? ""])
            switch event {
            case .statusChangeEvent:
                didUpdateStatusChangeEvent(node: node)
            case .statusResponse:
                didupdateStatusResponse(node: node)
            case .inventoryResponse:
                didUpdateEmptyMoneyItems(node: node)
            case .glyCashierEvent:
                manageGlyCashierEvent(node: node, data: data)
            case .incompleteTransaction:
                manageIncompleteTransaction(node: node)
            }
        } else {
            logger.error(message: "EventParsing Error", meta: ["input": String(data: data, encoding: .utf8) ?? ""])
        }
    }
}

// MARK: - Private Methods
private extension EventsHandler {
    func didUpdateStatusChangeEvent(node: XMLNode) {
        guard let rawValue = node.getElementsByTagName(TagName.status()).first?.data,
              let statusCode = StatusCode(rawValue: rawValue) else { return }
        gloryOutputDelegate.didUpdate(statusCode: statusCode)
    }
    
    func didupdateStatusResponse(node: XMLNode) {
        gloryOutputDelegate.didUpdateStacker(isFlagged: dataParser.didUpdateFlaggedStackers(node: node))
        let devStatus = dataParser.updateDevicesStatus(node: node)
        guard let billDevStatus = devStatus.bill, let coinDevStatus = devStatus.coin else { return }
        gloryOutputDelegate.didUpdate(billDevStatus: billDevStatus)
        gloryOutputDelegate.didUpdate(coinDevStatus: coinDevStatus)
    }
    
    func didUpdateFlaggedStackers(node: XMLNode) {
        if let childNodes = node.childNodes[safe:0]?.childNodes[safe:0]?.childNodes[safe:0]?.childNodes {
            gloryOutputDelegate.didUpdateStacker(isFlagged: childNodes.isEmpty)
        }
    }
    
    func didUpdateEventError(node: XMLNode) {
        guard let node = node.childNodes[safe:0],
              let errorCode = node.getElementsByTagName(TagName.errorCode()).first?.data,
              let url = node.getElementsByTagName(TagName.recoveryURL()).first?.data else { return }
        gloryOutputDelegate.didUpdateEventError(url: url, errorCode: Int(errorCode) ?? 0)
    }
    
    func didUpdateEmptyMoneyItems(node: XMLNode) {
        gloryOutputDelegate.didUpdate(emptyMoneyItems: (dataParser.parseMoneyItems(node.getElementsByTagName(TagName.cash())[safe:1], attributePrefix: "")))
    }
    
    func manageGlyCashierEvent(node: XMLNode, data: Data) {
        guard let rawValue = node.getElementsByTagName(TagName.glyCashierEvent()).first?.childNodes.first?.tag else { return }
        let glyCashierEvent = GlyCashierEvent(rawValue: rawValue)
        switch glyCashierEvent {
        case .eventRequireVerifyDenomination:
            didUpdateFlaggedStackers(node: node)
        case .eventDepositCountChange:
            didUpdateTransaction(data: data)
        case .eventError:
            didUpdateEventError(node: node)
        case .eventOpened:
            didUpdateStatusCode(node: node, glyCashierEvent: glyCashierEvent)
        case .eventClosed:
            didUpdateStatusCode(node: node, glyCashierEvent: glyCashierEvent)
        }
    }
    
    func manageIncompleteTransaction(node: XMLNode) {
        let cashNodes = node.getElementsByTagName(TagName.cash())
        guard let committedCashNodes = cashNodes[safe:0]?.childNodes,
              let currentCashNodes = cashNodes[safe:1]?.childNodes else { return }
        let insertedCashAmount = dataParser.computeInventoryDelta(commitedCashNodes: committedCashNodes, currentCashNodes: currentCashNodes)
        currentTransaction?.insertedCashAmount = insertedCashAmount
        currentTransaction?.sentBackCash = []
        gloryOutputDelegate.didFail(transaction: currentTransaction, error: IncompleteTransactionError())
    }
    
    func didUpdateTransaction(data: Data) {
        let transaction =  dataParser.updateInsertedCash(data: data, currentTransaction: currentTransaction)
        gloryOutputDelegate.didUpdate(transaction: transaction)
    }
    
    func didUpdateStatusCode(node: XMLNode, glyCashierEvent: GlyCashierEvent) {
        guard let statusCode = dataParser.updateDoorId(node: node, glyCashierEvent: glyCashierEvent) else { return }
        gloryOutputDelegate.didUpdate(statusCode: statusCode)
    }
}

