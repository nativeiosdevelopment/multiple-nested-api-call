//
//  UserSettings.swift
//  GloryFramework
//
//  Created by John Kricorian on 19/01/2022.
//

import Foundation

class UserSettings {
    
    static let _sharedInstance = UserSettings()
    
    class func shared() -> UserSettings {
        return _sharedInstance
    }
    
    internal var host: [String: String] {
        get {
            return UserDefaults.standard.object(forKey: "host") as? [String: String]  ?? [:]
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "host")
        }
    }
    
    internal var seqNo: Int {
        get {
            return UserDefaults.standard.object(forKey: "seqNo") as? Int  ?? 0
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "seqNo")
        }
    }
    
    internal var lastRefreshDate: Date {
        get {
            return UserDefaults.standard.object(forKey: "lastRefreshDate") as? Date  ?? Date()
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "lastRefreshDate")
        }
    }
    
}
