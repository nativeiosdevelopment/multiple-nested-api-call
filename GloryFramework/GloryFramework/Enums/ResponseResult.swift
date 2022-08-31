//
//  ResponseResult.swift
//  GloryFramework
//
//  Created by John Kricorian on 11/01/2022.
//

import Foundation

public enum ResponseResult: String  {
    case success
    case cancel
    case reset
    case occupiedByOther
    case occupiedByItself
    case notOccupied
    case designationDenominationShortage
    case cancelChangeShortage
    case changeShortage
    case exclusiveError
    case dispensedChangeInconsistency
    case autoRecoveryFailure
    case invalidSession
    case sessionTimeout
    case invalidCassetteNumber
    case improperCassette
    case exchangeRateError
    case countedCategory_2_3
    case duplicateTransaction
    case programInnerError
    case deviceError
    
    public typealias RawValue = String
    
    public var rawValue: RawValue {
        switch self {
        case .success:
            return "success"
        case .cancel:
            return "cancel"
        case .reset:
            return "reset"
        case .occupiedByOther:
            return "occupied by other"
        case .occupiedByItself:
            return "occupied by itself"
        case .notOccupied:
            return "not occupied"
        case .designationDenominationShortage:
            return "designation denomination shortage"
        case .cancelChangeShortage:
            return "cancel change shortage"
        case .changeShortage:
            return "change shortage"
        case .exclusiveError:
            return "exclusive error"
        case .dispensedChangeInconsistency:
            return "dispensed change inconsistency"
        case .autoRecoveryFailure:
            return "auto recovery failure"
        case .invalidSession:
            return "invalid session"
        case .sessionTimeout:
            return "session timeout"
        case .invalidCassetteNumber:
            return "invalid cassette number"
        case .improperCassette:
            return "improper cassette"
        case .exchangeRateError:
            return "exchange rate error"
        case .countedCategory_2_3:
            return "counted category 2 3"
        case .duplicateTransaction:
            return "duplicate transaction"
        case .programInnerError:
            return "program inner error"
        case .deviceError:
            return "device error"
        }
    }
    
    public init?(rawValue: RawValue) {
        switch rawValue {
        case "0":
            self = .success
        case "1":
            self = .cancel
        case "2":
            self = .reset
        case "3":
            self = .occupiedByOther
        case "5":
            self = .notOccupied
        case "6":
            self = .designationDenominationShortage
        case "9":
            self = .cancelChangeShortage
        case "10":
            self = .changeShortage
        case "11":
            self = .exclusiveError
        case "12":
            self = .dispensedChangeInconsistency
        case "13":
            self = .autoRecoveryFailure
        case "17":
            self = .occupiedByItself
        case "21":
            self = .invalidSession
        case "22":
            self = .sessionTimeout
        case "40":
            self = .invalidCassetteNumber
        case "41":
            self = .improperCassette
        case "43":
            self = .exchangeRateError
        case "44":
            self = .countedCategory_2_3
        case "96":
            self = .duplicateTransaction
        case "99":
            self = .programInnerError
        case "100":
            self = .deviceError
        default:
            return nil
        }
    }
}

