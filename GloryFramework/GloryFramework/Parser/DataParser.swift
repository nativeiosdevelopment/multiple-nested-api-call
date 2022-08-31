//
//  DataParser.swift
//  GloryFramework
//
//  Created by John Kricorian on 23/01/2022.
//

import Foundation

protocol DataParserProtocol: AnyObject {
    func parseDepositNodes(nodes: [XMLNode], attributePrefix: String) -> [Cash]
    func parseTransaction(nodes: [XMLNode], transaction: Transaction)
    func getRawValue(response: [XMLNode]?) -> String
    func updateInsertedCash(data: Data, currentTransaction: Transaction?) -> Transaction?
    func computeInventoryDelta(commitedCashNodes: [XMLNode], currentCashNodes: [XMLNode]) -> Int
    func parseMoneyItems(_ node: XMLNode?, attributePrefix: String?) -> [MoneyItem]
    func updateDoorId(node: XMLNode, glyCashierEvent: GlyCashierEvent) -> StatusCode?
    func didUpdateFlaggedStackers(node: XMLNode?) -> Bool
    func updateDevicesStatus(node: XMLNode?) -> (bill: DeviceStatus?, coin: DeviceStatus?)
    func didUpdateStatus(node: XMLNode?, completionHandler: @escaping (GetMachineStatusUseCase))
}

class DataParser {
        
    private func filterEmptyMoneyItems(_ moneyItems: [MoneyItem]) -> [MoneyItem] {
        return moneyItems.filter { $0.status == .nearEmpty || $0.status == .empty }
    }
}

// MARK: - DataParserProtocol
extension DataParser: DataParserProtocol {
    internal func parseDepositNodes(nodes: [XMLNode], attributePrefix: String = "") -> [Cash] {
        var cashList: [Cash] = []
        for node in nodes {
            guard let currency = node.getAttribute("\(attributePrefix)cc"),
                  let facialValue = node.getAttribute("\(attributePrefix)fv"),
                  let piece = node.childNodes.first?.data else { return [] }
            let cash = Cash(piece: Int(piece) ?? 0, facialValue: facialValue, currency: currency)
            cashList.append(cash)
        }
        return cashList
    }
    
    internal func parseTransaction(nodes: [XMLNode], transaction: Transaction) {
        guard let node = nodes.first, let manualDeposit = node.getElementsByTagName(TagName.manualDeposit()).first?.data else { return }
        transaction.manualDeposit = manualDeposit.toInt()
        for node in node.getElementsByTagName(TagName.cash()) {
            if node.attributes["n:type"] == "1" {
                transaction.insertedCash = parseDepositNodes(nodes: node.childNodes, attributePrefix: "n:")
            } else if node.attributes["n:type"] == "2" {
                transaction.sentBackCash = parseDepositNodes(nodes: node.childNodes, attributePrefix: "n:")
            }
        }
    }
    
    internal func getRawValue(response: [XMLNode]?) -> String {
        guard let result = response?.first?.attributes["n:result"] else { return "" }
        return result
    }
    
    internal func updateInsertedCash(data: Data, currentTransaction: Transaction?) -> Transaction? {
        guard let nodes = MicroDOM(data: data).parse()?.getElementsByTagName(TagName.denomination()), !nodes.isEmpty else { return nil }
        currentTransaction?.insertedCash = parseDepositNodes(nodes: nodes)
        return currentTransaction
    }
        
    internal func computeInventoryDelta(commitedCashNodes: [XMLNode], currentCashNodes: [XMLNode]) -> Int {
        let committedStackers = parseDepositNodes(nodes: commitedCashNodes)
        let currentStackers = parseDepositNodes(nodes: currentCashNodes)
        var currentInventoryOutput = 0
        var commitedInventoryOutput = 0
        currentStackers.forEach { currentInventoryOutput += $0.facialValue * $0.piece }
        committedStackers.forEach { commitedInventoryOutput += $0.facialValue * $0.piece }
        
        return currentInventoryOutput - commitedInventoryOutput
    }
    
    internal func parseMoneyItems(_ node: XMLNode?, attributePrefix: String? = "") -> [MoneyItem]  {
        guard let childNodes = node?.getElementsByTagName(TagName.denomination()) else { return [] }
        var moneyItems: [MoneyItem] = []
        for childNode in childNodes {
            guard let facialValue = childNode.attributes["\(attributePrefix ?? "")fv"],
                  let devid = childNode.attributes["\(attributePrefix ?? "")devid"],
                  let currency = childNode.attributes["\(attributePrefix ?? "")cc"],
                  let piece = childNode.childNodes[safe:0]?.data,
                  let rawValue = childNode.childNodes[safe:1]?.data,
                  let status = InventoryStatus(rawValue: rawValue) else { return [] }
            let item = MoneyItem(facialValue: Int(facialValue) ?? 0, devid: devid, currency: currency, piece: Int(piece) ?? 0, status: status)
            moneyItems.append(item)
        }
        return filterEmptyMoneyItems(moneyItems)
    }
    
    internal func updateDoorId(node: XMLNode, glyCashierEvent: GlyCashierEvent) -> StatusCode? {
        var billDevStatus: DeviceStatus?
        var coinDevStatus: DeviceStatus?
        guard let rawValue = node.childNodes.first?.getAttribute("devid"),
              let devId = DevId(rawValue: rawValue) else { return nil }
        switch devId {
        case .bill:
            if glyCashierEvent == .eventClosed {
                billDevStatus = .state_idle
            } else if glyCashierEvent == .eventOpened {
                billDevStatus = .state_busy
            }
        case .coin:
            if glyCashierEvent == .eventClosed {
                coinDevStatus = .state_idle
            } else if glyCashierEvent == .eventOpened {
                coinDevStatus = .state_busy
            }
        }
        if billDevStatus == .state_idle && coinDevStatus == .state_idle {
            return .idle
        } else if billDevStatus == .state_idle && coinDevStatus == nil {
            return .idle
        } else if billDevStatus == nil && coinDevStatus == .state_idle {
            return .idle
        } else {
            return .inoperative_cash_recycler
        }
    }
    
    internal func didUpdateFlaggedStackers(node: XMLNode?) -> Bool {
        guard let nodes = node?.getElementsByTagName(TagName.requireVerifyDenomination()) else { return false }
        for node in nodes {
            if node.attributes["val"] == "1" {
                return true
            }
        }
        return false
    }
    
    internal func updateDevicesStatus(node: XMLNode?) -> (bill: DeviceStatus?, coin: DeviceStatus?) {
        guard let billRawValue = node?.getElementsByTagName(TagName.devStatus())[safe:0]?.getAttribute("st"),
              let bill = DeviceStatus(rawValue: billRawValue),
              let coinRawValue = node?.getElementsByTagName(TagName.devStatus())[safe:1]?.getAttribute("st"),
              let coin = DeviceStatus(rawValue: coinRawValue) else { return (nil, nil) }
        return (bill, coin)
    }
    
    internal func didUpdateStatus(node: XMLNode?, completionHandler: @escaping (GetMachineStatusUseCase)) {
        guard let rawValue = node?.childNodes.first?.data,
              let statusCode = StatusCode(rawValue: rawValue),
              let billRawValue = node?.getElementsByTagName(TagName.devStatus())[safe:0]?.getAttribute("n:st"),
              let coinRawValue = node?.getElementsByTagName(TagName.devStatus())[safe:1]?.getAttribute("n:st"),
              let billDevStatus = DeviceStatus(rawValue: billRawValue),
              let coinDevStatus = DeviceStatus(rawValue: coinRawValue) else {
            let error = StatusError(error: nil, statusCode: nil)
            completionHandler(nil, nil, nil, error)
            return
        }
        completionHandler(statusCode, billDevStatus, coinDevStatus, nil)
    }
}

