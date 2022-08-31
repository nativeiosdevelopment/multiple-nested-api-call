//
//  String+Extensions.swift
//  GlorySDK
//
//  Created by John Kricorian on 22/07/2021.
//

import Foundation

public extension String {
    
    func toInt() -> Int {
        return NumberFormatter().number(from: self)?.intValue ?? 0
    }
}

