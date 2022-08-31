//
//  DeviceStatus.swift
//  GloryFramework
//
//  Created by John Kricorian on 11/01/2022.
//

import Foundation

@objc public enum DeviceStatus: Int, RawRepresentable {
    case state_initialize
    case state_idle
    case state_idle_occupy
    case state_deposit_busy
    case state_deposit_counting
    case state_deposit_end
    case state_wait_store
    case state_store_busy
    case state_store_end
    case state_wait_return
    case state_count_busy
    case state_count_counting
    case state_replenish_busy
    case state_dispense_busy
    case state_wait_dispense
    case state_refill
    case state_refill_counting
    case state_refill_end
    case state_reset
    case state_collect_busy
    case state_verify_busy
    case state_verifycollect_busy
    case state_inventory_clear
    case state_inventory_adjust
    case state_download_busy
    case state_log_read_busy
    case state_busy
    case state_error
    case state_com_error
    case state_wait_for_reset
    case state_config_error
    case state_locked_by_other_session
    
    public typealias RawValue = String
    
    public var rawValue: RawValue {
        switch self {
        case .state_initialize:
            return "state_initialize"
        case .state_idle:
            return "state_idle"
        case .state_idle_occupy:
            return "state_idle_occupy"
        case .state_deposit_busy:
            return "state_deposit_busy"
        case .state_deposit_counting:
            return "state_deposit_counting"
        case .state_deposit_end:
            return "state_deposit_end"
        case .state_wait_store:
            return "state_wait_store"
        case .state_store_busy:
            return "state_store_busy"
        case .state_store_end:
            return "state_store_end"
        case .state_wait_return:
            return "state_wait_return"
        case .state_count_busy:
            return "state_count_busy"
        case .state_count_counting:
            return "state_count_counting"
        case .state_replenish_busy:
            return "state_replenish_busy"
        case .state_dispense_busy:
            return "state_dispense_busy"
        case .state_wait_dispense:
            return "state_wait_dispense"
        case .state_refill:
            return "state_refill"
        case .state_refill_counting:
            return "state_refill_counting"
        case .state_refill_end:
            return "state_refill_end"
        case .state_reset:
            return "state_reset"
        case .state_collect_busy:
            return "state_collect_busy"
        case .state_verify_busy:
            return "state_verify_busy"
        case .state_verifycollect_busy:
            return "state_verifycollect_busy"
        case .state_inventory_clear:
            return "state_inventory_clear"
        case .state_inventory_adjust:
            return "state_inventory_adjust"
        case .state_download_busy:
            return "state_download_busy"
        case .state_log_read_busy:
            return "state_log_read_busy"
        case .state_busy:
            return "state_busy"
        case .state_error:
            return "state_error"
        case .state_com_error:
            return "state_com_error"
        case .state_wait_for_reset:
            return "state_wait_for_reset"
        case .state_config_error:
            return "state_config_error"
        case .state_locked_by_other_session:
            return "state_locked_by_other_session"
        }
    }
    
    public init?(rawValue: RawValue) {
        switch rawValue {
        case "0":
            self = .state_initialize
        case "1000":
            self = .state_idle
        case "1500":
            self = .state_idle_occupy
        case "2000":
            self = .state_deposit_busy
        case "2050":
            self = .state_deposit_counting
        case "2055":
            self = .state_deposit_end
        case "2100":
            self = .state_wait_store
        case "2200":
            self = .state_store_busy
        case "2300":
            self = .state_store_end
        case "2500":
            self = .state_wait_return
        case "2600":
            self = .state_count_busy
        case "2610":
            self = .state_count_counting
        case "2700":
            self = .state_replenish_busy
        case "3000":
            self = .state_dispense_busy
        case "3100":
            self = .state_wait_dispense
        case "4000":
            self = .state_refill
        case "4050":
            self = .state_refill_counting
        case "4055":
            self = .state_refill_end
        case "5000":
            self = .state_reset
        case "6000":
            self = .state_collect_busy
        case "6500":
            self = .state_verify_busy
        case "6600":
            self = .state_verifycollect_busy
        case "7000":
            self = .state_inventory_clear
        case "7100":
            self = .state_inventory_adjust
        case "8000":
            self = .state_download_busy
        case "8100":
            self = .state_log_read_busy
        case "9100":
            self = .state_busy
        case "9200":
            self = .state_error
        case "9300":
            self = .state_com_error
        case "9400":
            self = .state_wait_for_reset
        case "9500":
            self = .state_config_error
        case "50000":
            self = .state_locked_by_other_session
        default:
            return nil
        }
    }
}
