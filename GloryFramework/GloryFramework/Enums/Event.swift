//
//  Event.swift
//  GloryFramework
//
//  Created by John Kricorian on 11/01/2022.
//

import Foundation

public enum Event: String {
    case statusChangeEvent
    case statusResponse
    case inventoryResponse
    case glyCashierEvent
    case incompleteTransaction
    
    public typealias RawValue = String
    
    public var rawValue: RawValue {
        switch self {
        case .statusResponse:
            return "StatusResponse"
        case .inventoryResponse:
            return "InventoryResponse"
        case .glyCashierEvent:
            return "GlyCashierEvent"
        case .statusChangeEvent:
            return "StatusChangeEvent"
        case .incompleteTransaction:
            return "IncompleteTransaction"
        }
    }
    
    public init?(rawValue: RawValue) {
        switch rawValue {
        case "StatusResponse":
            self = .statusResponse
        case "InventoryResponse":
            self = .inventoryResponse
        case "GlyCashierEvent":
            self = .glyCashierEvent
        case "StatusChangeEvent":
            self = .statusChangeEvent
        case "IncompleteTransaction":
            self = .incompleteTransaction
        default:
            return nil
        }
    }
}


