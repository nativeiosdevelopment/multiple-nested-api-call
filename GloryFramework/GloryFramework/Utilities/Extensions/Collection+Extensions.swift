//
//  Collection+Extensions.swift
//  GloryFramework
//
//  Created by John Kricorian on 22/10/2021.
//

import Foundation

extension Collection where Indices.Iterator.Element == Index {
    
   public subscript(safe index: Index) -> Iterator.Element? {
     return (startIndex <= index && index < endIndex) ? self[index] : nil
   }
}
