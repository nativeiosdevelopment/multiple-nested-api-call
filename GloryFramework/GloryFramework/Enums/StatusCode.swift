//
//  StatusCode.swift
//  GloryFramework
//
//  Created by John Kricorian on 11/01/2022.
//

import Foundation

public enum StatusCode: String {
        
    case initializing = "0"
    case idle = "1"
    case atStartingChange = "2"
    case waitingInsertionOfCashByChange = "3"
    case counting = "4"
    case dispensing = "5"
    case waitingRemovalOfCashInReject = "6"
    case waitingRemovalOfCashOut = "7"
    case resetting = "8"
    case cancelingOfChangeOperation = "9"
    case calculatingChangeAmount = "10"
    case cancelingDeposit = "11"
    case collecting = "12"
    case error = "13"
    case uploadFirmware = "14"
    case readingLog = "15"
    case waitingReplenishment = "16"
    case countingReplenishment = "17"
    case unlocking = "18"
    case waitingInventory = "19"
    case fixedDepositAmount = "20"
    case fixedDispenseAmount = "21"
    case waitingCancellation = "23"
    case countedCategory2 = "24"
    case waitingDepositEnd = "25"
    case waitingRemovalOfCOFT = "26"
    case sealing = "27"
    case autoRecovery = "30"
    case programBusy = "40"
    case waiting = "41"
    case unknown = "99"
    case inoperative_cash_recycler = "100"
    case notConnected
    case status_internal_error
    case status_idle
    case status_counting
    case status_using_own
    case status_busy
    case status_error
    case status_error_communication
    case status_dll_initialize_busy
    
    public init?(rawValue: String) {
        switch rawValue {
        case "0":
            self = .initializing
        case "1":
            self = .idle
        case "2":
            self = .atStartingChange
        case "3":
            self = .waitingInsertionOfCashByChange
        case "4":
            self = .counting
        case "5":
            self = .dispensing
        case "6":
            self = .waitingRemovalOfCashInReject
        case "7":
            self = .waitingRemovalOfCashOut
        case "8":
            self = .resetting
        case "9":
            self = .cancelingOfChangeOperation
        case "10":
            self = .calculatingChangeAmount
        case "11":
            self = .cancelingDeposit
        case "12":
            self = .collecting
        case "13":
            self = .error
        case "14":
            self = .uploadFirmware
        case "15":
            self = .readingLog
        case "16":
            self = .waitingReplenishment
        case "17":
            self = .countingReplenishment
        case "18":
            self = .unlocking
        case "19":
            self = .waitingInventory
        case "20":
            self = .fixedDepositAmount
        case "21":
            self = .fixedDispenseAmount
        case "23":
            self = .waitingCancellation
        case "24":
            self = .countedCategory2
        case "25":
            self = .waitingDepositEnd
        case "26":
            self = .waitingRemovalOfCOFT
        case "27":
            self = .sealing
        case "30":
            self = .autoRecovery
        case "40":
            self = .programBusy
        case "41":
            self = .waiting
        case "99":
            self = .unknown
        case "100":
            self = .inoperative_cash_recycler
        default:
            return nil
        }
    }
}
