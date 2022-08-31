//
//  TagName.swift
//  GloryFramework
//
//  Created by John Kricorian on 31/01/2022.
//

import Foundation

enum TagName: String {
    case denomination = "Denomination"
    case manualDeposit = "n:ManualDeposit"
    case cash = "Cash"
    case status = "Status"
    case errorCode = "ErrorCode"
    case recoveryURL = "RecoveryURL"
    case glyCashierEvent = "GlyCashierEvent"
    case requireVerifyDenomination = "RequireVerifyDenomination"
    case devStatus = "DevStatus"
    case soapenvBody = "soapenv:Body"
    
    func callAsFunction() -> String {
        return self.rawValue
    }
}


