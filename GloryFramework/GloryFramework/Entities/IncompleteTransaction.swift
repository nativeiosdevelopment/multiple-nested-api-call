//
//  IncompleteTransaction.swift
//  GloryFramework
//
//  Created by John Kricorian on 30/09/2021.
//

import Foundation

 public class IncompleteTransaction: NSObject {
    
    let transactionId: String
    let transactionName: String
    let committed: Committed
    let current: Current
    let manualDepositInfo: ManualDepositInfo
    let depositCategoryInfo: DepositCategoryInfo
    

    internal init(transactionId: String, transactionName: String, committed: Committed, current: Current, manualDepositInfo: ManualDepositInfo, depositCategoryInfo: DepositCategoryInfo) {
        self.transactionId = transactionId
        self.transactionName = transactionName
        self.committed = committed
        self.current = current
        self.manualDepositInfo = manualDepositInfo
        self.depositCategoryInfo = depositCategoryInfo
    }
    
     public class Committed: NSObject {
        
        let cashType: CashType
        let denomination: Denomination
        
        internal init(cashType: CashType, denomination: Denomination) {
            self.cashType = cashType
            self.denomination = denomination
        }
    }

     public class Current: NSObject {
        
        let cashType: CashType
        let denomination: Denomination
        let status: InventoryStatus
                
        internal init(cashType: CashType, denomination: Denomination, status: InventoryStatus) {
            self.cashType = cashType
            self.denomination = denomination
            self.status = status
        }
    }
    
     public class Denomination: NSObject {
        
        let piece: String
        let status: String
        
        internal init(piece: String, status: String) {
            self.piece = piece
            self.status = status
        }
    }

     public class ManualDepositInfo: NSObject {
         public class DepositCurrency: NSObject {
             public class Currency: NSObject {
            }
        }
    }

     public class DepositCategoryInfo: NSObject {
        
        let cashType: CashType
        let denomination: Denomination
        
        internal init(cashType: CashType, denomination: Denomination) {
            self.cashType = cashType
            self.denomination = denomination
        }
    }
}


