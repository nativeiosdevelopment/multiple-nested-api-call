//
//  GloryLogger.swift
//  GloryFramework
//
//  Created by John Kricorian on 16/02/2022.
//


public protocol GloryLoggerDelegate: AnyObject {
    func debug(message: String, meta: [String: Any]?)
    func info(message: String, meta: [String: Any]?)
    func error(message: String, meta: [String: Any]?)
}

