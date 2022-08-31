//
//  StatusResponse.swift
//  GloryFramework
//
//  Created by John Kricorian on 11/01/2022.
//

import Foundation

public enum ServerStatusResponse: String  {
    case success
    case invalidSession
    case sessionTimeout
    case numberOfRegistrationOver
    case parameterError
    case programInnerError
    case notConnected
    
    public typealias RawValue = String
    
    public var rawValue: RawValue {
        switch self {
        case .success:
            return "success"
        case .invalidSession:
            return "invalid session"
        case .sessionTimeout:
            return "session timeout"
        case .numberOfRegistrationOver:
            return "number of registration over"
        case .parameterError:
            return "parameter error"
        case .programInnerError:
            return "program inner error"
        case .notConnected:
            return "not connected"
        }
    }
    
    public init?(rawValue: RawValue) {
        switch rawValue {
        case "0":
            self = .success
        case "21":
            self = .invalidSession
        case "22":
            self = .sessionTimeout
        case "36":
            self = .numberOfRegistrationOver
        case "98":
            self = .parameterError
        case "99":
            self = .programInnerError
        case "100":
            self = .notConnected
        default:
            return nil
        }
    }
}


