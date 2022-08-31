//
//  ExitCoverStatus.swift
//  GloryFramework
//
//  Created by John Kricorian on 11/01/2022.
//

import Foundation

public enum CoverStatus: String  {
    case success = "0"
    case occupiedByOther = "3"
    case notOccupied = "5"
    case exclusiveError = "11"
    case invalidSession = "21"
    case sessionTimeout = "22"
    case passwordExpired = "46"
    case programInnerError = "99"
    case deviceError = "100"
    
    public init?(rawValue: String) {
        switch rawValue {
        case "0" : self = .success
        case "3" : self = .occupiedByOther
        case "5" : self = .notOccupied
        case "11" : self = .exclusiveError
        case "21" : self = .success
        case "22" : self = .invalidSession
        case "46" : self = .sessionTimeout
        case "99" : self = .programInnerError
        case "100" : self = .deviceError
        default:
            return nil
        }
    }
}

