//
//  DoorId.swift
//  GloryFramework
//
//  Created by John Kricorian on 11/01/2022.
//

import Foundation

public enum DoorId: String {
    case unknown
    case collectionDoor
    case maintenanceDoorOrExitCover
    case upperDoor
    case jamDoor
        
    public typealias RawValue = String
    
    public var rawValue: RawValue {
        switch self {
        case .unknown:
            return "unknown"
        case .collectionDoor:
            return "collection door"
        case .maintenanceDoorOrExitCover:
            return "maintenance door(RBW-100) or exit cover(RBW-150, RBW-50)"
        case .upperDoor:
            return "upper door"
        case .jamDoor:
            return "jam door"
        }
    }
    
    public init?(rawValue: RawValue) {
        switch rawValue {
        case "0":
            self = .unknown
        case "1":
            self = .collectionDoor
        case "2":
            self = .maintenanceDoorOrExitCover
        case "3":
            self = .upperDoor
        case "4":
            self = .jamDoor
        default:
            return nil
        }
    }
}








