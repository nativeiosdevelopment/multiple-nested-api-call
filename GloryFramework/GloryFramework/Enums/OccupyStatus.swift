//
//  Enums.swift
//  GloryFramework
//
//  Created by John Kricorian on 30/07/2021.
//

import Foundation

@objc public enum OccupyStatus: Int, RawRepresentable  {
    case success
    case occupiedByOther
    case occupationNotAvailable
    case occupiedByItself
    case invalidSession
    case sessionTimeout
    case programInnerError
    case unknown
    
    public typealias RawValue = String
    
    public var rawValue: RawValue {
        switch self {
        case .success:
            return "success"
        case .occupiedByOther:
            return "occupied by other"
        case .occupationNotAvailable:
            return "occupation not available"
        case .occupiedByItself:
            return "occupied by itself"
        case .invalidSession:
            return "invalid session"
        case .sessionTimeout:
            return "session timeout"
        case .programInnerError:
            return "program inner error"
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
        case "4":
            self = .occupationNotAvailable
        case "17":
            self = .occupiedByItself
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
