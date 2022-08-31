//
//  UnRegisterEventStatus.swift
//  GloryFramework
//
//  Created by John Kricorian on 11/01/2022.
//

import Foundation

public enum UnRegisterEventStatus: String  {
    case success
    case invalidSession
    case sessionTimeout
    case parameterError
    case programInnerError
    case notYetRegister
    
    public typealias RawValue = String
    
    public var rawValue: RawValue {
        switch self {
        case .success:
            return "success"
        case .invalidSession:
            return "invalid session"
        case .sessionTimeout:
            return "session timeout"
        case .parameterError:
            return "parameter error"
        case .programInnerError:
            return "program inner error"
        case .notYetRegister:
            return "not yet register"
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
        case "98":
            self = .parameterError
        case "99":
            self = .programInnerError
        case "100":
            self = .notYetRegister
        default:
            return nil
        }
    }
}
