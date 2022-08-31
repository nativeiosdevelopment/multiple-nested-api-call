//
//  Transaction.swift
//  GloryFramework
//
//  Created by John Kricorian on 16/09/2021.
//

import Foundation

 public class Transaction: NSObject {
    
    public var amount: Int
    public var manualDeposit: Int
    public var insertedCashAmount: Int = 0
    public var insertedCash: [Cash] {
        didSet {
            insertedCashAmount = insertedCash.compactMap { cash in
                cash.piece * cash.facialValue
            }.reduce(0, +)
        }
    }
    public var sentBackCash: [Cash]
    
    internal init(amount: Int, manualDeposite: Int, insertedCash: [Cash], sentBackCash: [Cash]) {
        self.amount = amount
        self.manualDeposit = manualDeposite
        self.insertedCash = insertedCash
        self.sentBackCash = sentBackCash
    }
    
    public var leftToPay: Int {
        return amount - alreadyPaid
    }
    
    public var alreadyPaid: Int {
        return insertedCashAmount - sentBackCashAmount
    }
        
    public var sentBackCashAmount: Int {
        return sentBackCash.compactMap { cash in
            cash.piece * cash.facialValue
        }.reduce(0, +)
    }
}

 public class Cash: NSObject {
    
    public var piece: Int
    public var facialValue: Int
    public var currency: String
    
    internal init(piece: Int, facialValue: String, currency: String) {
        self.piece = piece
        self.facialValue = facialValue.toInt()
        self.currency = currency
    }
}
