//
//  AdjustTimeStatus.swift
//  GloryFramework
//
//  Created by John Kricorian on 11/01/2022.
//

import Foundation

public enum AdjustTimeStatus: String  {
    case unknown
    case error
    case success
    case occupiedByOther
    case notOccupied
    case exclusiveError
    case invalidSession
    case sessionTimeout
    case parameterError
    case programInnerError
    case deviceError
    
    public typealias RawValue = String
    
    public var rawValue: RawValue {
        switch self {
        case .error:
            return "error"
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
        case .parameterError:
            return "parameter error"
        case .deviceError:
            return "device error"
        case .unknown:
            return "unknown"
        }
    }
    
    public init?(rawValue: RawValue) {
        switch rawValue {
        case "0":
            self = .success
        case "3":
            self = .occupiedByOther
        case "5 ":
            self = .notOccupied
        case "11":
            self = .exclusiveError
        case "21":
            self = .invalidSession
        case "22":
            self = .sessionTimeout
        case "98":
            self = .parameterError
        case "99":
            self = .programInnerError
        case "100":
            self = .deviceError
        case "999":
            self = .error
        case "1000":
            self = .unknown
        default:
            return nil
        }
    }
}
