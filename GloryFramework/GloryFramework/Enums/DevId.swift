//
//  DevId.swift
//  GloryFramework
//
//  Created by John Kricorian on 11/01/2022.
//

import Foundation

internal enum DevId: String {
    case bill = "1"
    case coin = "2"
    
    init?(rawValue: String) {
        switch rawValue {
        case "1": self = .bill
        case "2": self = .coin
        default:
            return nil
        }
    }
}



