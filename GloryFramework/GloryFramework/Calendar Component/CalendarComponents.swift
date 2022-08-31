//
//  CalendarComponents.swift
//  GloryFramework
//
//  Created by John Kricorian on 21/12/2021.
//

import Foundation

class CalendarComponents {
    
    var year: String {
        String(Calendar.current.component(.year, from: Date()))
    }
    
    var month: String {
        String(Calendar.current.component(.month, from: Date()))
    }
    
    var day: String {
        String(Calendar.current.component(.day, from: Date()))
    }
    
    var hour: String {
        String(Calendar.current.component(.hour, from: Date()))
    }
    
    var minute: String {
        String(Calendar.current.component(.minute, from: Date()))
    }
    
    var second: String {
        String(Calendar.current.component(.second, from: Date()))
    }
}
