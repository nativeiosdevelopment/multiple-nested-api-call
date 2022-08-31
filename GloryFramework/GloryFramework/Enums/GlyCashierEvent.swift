//
//  GlyCashierEvent.swift
//  GloryFramework
//
//  Created by John Kricorian on 11/01/2022.
//

import Foundation

public enum GlyCashierEvent: String {
    case eventDepositCountChange
    case eventError
    case eventRequireVerifyDenomination
    case eventOpened
    case eventClosed
    
    public init(rawValue: String) {
        switch rawValue {
        case "eventDepositCountChange":
            self = .eventDepositCountChange
        case "eventError":
            self = .eventError
        case "eventRequireVerifyDenomination":
            self = .eventRequireVerifyDenomination
        case "eventOpened":
            self = .eventOpened
        case "eventClosed":
            self = .eventClosed
        default:
            self = .eventError
        }
    }
}


