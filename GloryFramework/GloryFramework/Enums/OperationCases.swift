//
//  OperationCases.swift
//  GloryFramework
//
//  Created by John Kricorian on 11/01/2022.
//

import Foundation

public enum Operation: String {
    case adjustTime = "AdjustTime"
    case open = "Open"
    case status = "GetStatus"
    case occupy = "Occupy"
    case release = "Release"
    case close = "Close"
    case change =  "Change"
    case changeCancel = "ChangeCancel"
    case inventory = "Inventory"
    case registerEvent = "RegisterEvent"
    case unregisterEvent = "UnRegisterEvent"
    case reset = "Reset"
    case openCoverExit = "OpenExitCover"
    case closeCoverExit = "CloseExitCover"

  public var operationName: String {
      if self == .status {
          return "GetStatus"
      }
      return "\(self.rawValue)Operation"
  }

  public var requestName: String {
      if self == .status {
          return "StatusRequest"
      }
      return "\(self.rawValue)Request"
  }

  public var responseTag: String {
      if self == .status {
          return "Status"
      }
      return "n:\(self.rawValue)Response"
  }
}
