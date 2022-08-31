//
//  TypeAlias.swift
//  GlorySDK
//
//  Created by John Kricorian on 19/07/2021.
//

import Foundation

typealias GetNodesUseCase = (Result<[XMLNode], Error>) -> Void
public typealias ConnectedStatusUseCase = (Bool) -> Void
public typealias GetStatusUseCase = (Result<MachineStatus, Error>) -> Void
public typealias GetMachineStatusUseCase = (StatusCode?, DeviceStatus?, DeviceStatus?, Error?) -> Void
public typealias OccupyUseCase = ((Result<OccupyStatus, Error>) -> Void)?
public typealias CoverUseCase = ((Result<CoverStatus, Error>) -> Void)?
public typealias ChangeUseCase = (Transaction) -> Void
public typealias ChangeRequestHandler = (Result<Transaction, Error>) -> Void
public typealias OpenUseCase = (Result<String, Error>) -> Void
public typealias ChangeCancelUseCase = ((Result<ChangeCancelStatus, Error>) -> Void)?
public typealias RegisterEventUseCase = ((Result<ServerStatusResponse, Error>) -> Void)?
public typealias StartServerUseCase = ((Result<Bool, Error>) -> Void)?
public typealias UnRegisterEventUseCase = ((Result<UnRegisterEventStatus, Error>) -> Void)?
public typealias InventoryUseCase = ((Result<[MoneyItem], Error>) -> Void)?
public typealias AdjustTimeStatusUseCase = ((Result<AdjustTimeStatus, Error>) -> Void)?
public typealias ReleaseAndCloseUseCase = ((Bool) -> Void)?



