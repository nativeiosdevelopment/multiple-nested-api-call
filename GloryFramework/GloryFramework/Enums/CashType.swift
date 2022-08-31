//
//  CashType.swift
//  GloryFramework
//
//  Created by John Kricorian on 11/01/2022.
//

import Foundation

public enum CashType: String  {
    case cashInInformation
    case cashOutInformation
    case deviceInternalInventory
    case dispensableInventory
    case denominationControl
    case paymentDenomination
    case verificationDenomination
    case cashOutInformationToCOFB
    case mixedStackerToExit
    case ifCollectionCassetteToExit
    case verifyCollectWithIFCollectionCassetteOption
    
    public typealias RawValue = String
    
    public var rawValue: RawValue {
        switch self {
        case .cashInInformation:
            return "cash in information"
        case .cashOutInformation:
            return "cash out information"
        case .deviceInternalInventory:
            return "device internal inventory"
        case .dispensableInventory:
            return "dispensable inventory"
        case .denominationControl:
            return "denomination control"
        case .paymentDenomination:
            return "payment denomination"
        case .verificationDenomination:
            return "verification denomination"
        case .cashOutInformationToCOFB:
            return "cashOut information to COFB"
        case .mixedStackerToExit:
            return "mixed stacker to exit"
        case .ifCollectionCassetteToExit:
            return "if collection cassette to exit"
        case .verifyCollectWithIFCollectionCassetteOption:
            return "verify collect with if collection cassette option"
        }
    }
    
    public init?(rawValue: RawValue) {
        switch rawValue {
        case "1":
            self = .cashInInformation
        case "2":
            self = .cashOutInformation
        case "3":
            self = .deviceInternalInventory
        case "4":
            self = .dispensableInventory
        case "5":
            self = .denominationControl
        case "6":
            self = .paymentDenomination
        case "7":
            self = .verificationDenomination
        case "8":
            self = .cashOutInformationToCOFB
        case "9":
            self = .mixedStackerToExit
        case "10":
            self = .ifCollectionCassetteToExit
        case "11":
            self = .verifyCollectWithIFCollectionCassetteOption
        default:
            return nil
        }
    }
}
