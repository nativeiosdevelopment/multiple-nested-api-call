//
//  MoneyItem.swift
//  GloryFramework
//
//  Created by John Kricorian on 16/09/2021.
//

import Foundation

 public class MoneyItem: NSObject {
    
    internal init(facialValue: Int, devid: String, currency: String, piece: Int, status: InventoryStatus) {
        self.facialValue = facialValue
        self.devid = devid
        self.currency = currency
        self.status = status
        self.piece = piece
    }
    
    public let facialValue: Int
    public let devid: String
    public let currency: String
    public let piece: Int
    public let status: InventoryStatus
    
    public func isNearEmpty() -> Bool {
        status == .empty || status == .nearEmpty 
    }
}


