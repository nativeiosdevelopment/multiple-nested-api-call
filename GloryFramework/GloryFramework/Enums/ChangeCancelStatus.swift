//
//  ChangeCancelStatus.swift
//  GloryFramework
//
//  Created by John Kricorian on 11/02/2022.
//

import Foundation

public enum ChangeCancelStatus: String  {
    case success
    case occupiedByOther
    case notOccupied
    case exclusiveError
    case invalidSession
    case sessionTimeout
    case programInnerError
    
    public typealias RawValue = String
    
    public var rawValue: RawValue {
        switch self {
        case .success:
            return "success"
        case .occupiedByOther:
            return "occupied by other"
        case .notOccupied:
            return "not occupied"
        case .invalidSession:
            return "invalid session"
        case .sessionTimeout:
            return "session timeout"
        case .programInnerError:
            return "program inner error"
        case .exclusiveError:
            return "exclusive error"
        }
    }
    
    public init?(rawValue: RawValue) {
        switch rawValue {
        case "0":
            self = .success
        case "3":
            self = .occupiedByOther
        case "5":
            self = .notOccupied
        case "11":
            self = .exclusiveError
        case "21":
            self = .invalidSession
        case "22":
            self = .sessionTimeout
        case "99":
            self = .programInnerError
        default:
            return nil
        }
    }
}

