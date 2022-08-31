//
//  InventoryStatus.swift
//  GloryFramework
//
//  Created by John Kricorian on 11/01/2022.
//

import Foundation

public enum InventoryStatus: String  {
    case empty
    case nearEmpty
    case exist
    case nearFull
    case full
    case restriction
    case missing
    case n_a
    
    public typealias RawValue = String
    
    public var rawValue: RawValue {
        switch self {
        case .empty:
            return "empty"
        case .nearEmpty:
            return "near empty"
        case .exist:
            return "exist"
        case .nearFull:
            return "near Full"
        case .full:
            return "full"
        case .restriction:
            return "restriction"
        case .missing:
            return "missing"
        case .n_a:
            return "n_a"
        }
    }
    
    public init?(rawValue: RawValue) {
        switch rawValue {
        case "0":
            self = .empty
        case "1":
            self = .nearFull
        case "2":
            self = .exist
        case "3":
            self = .nearFull
        case "4":
            self = .full
        case "20":
            self = .restriction
        case "21":
            self = .missing
        case "22":
            self = .n_a
        default:
            return nil
        }
    }
}


