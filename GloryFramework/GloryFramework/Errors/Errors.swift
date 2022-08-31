//
//  Errs.swift
//  GloryFramework
//
//  Created by John Kricorian on 07/12/2021.
//

import Foundation

public struct NetworkRequestError: Error {
    let error: Error?
    
    var localizedDescription: String {
        return error?.localizedDescription ?? "Network request error - no other information"
    }
}

public struct CancelledTransactionError: Error {    
    var localizedDescription: String {
        return "La transaction a été annulée"
    }
}

public struct ApiError: Error {
    let data: Data?
    let httpUrlResponse: HTTPURLResponse
}

public struct ResponseError: Error {
    public let responseResult: ResponseResult?
    public let message: String?
}

public struct FormatError: Error {}

public struct StatusResponseError: Error {
    public let serverStatusResponse: ServerStatusResponse
}

public struct OccupyStatusError: Error {
    
    public let occupyStatus: OccupyStatus?
    
    public init(occupyStatus: OccupyStatus) {
        self.occupyStatus = occupyStatus
    }
}

public struct AdjustTimeError: Error {
    public let adjustTimeStatus: AdjustTimeStatus
}

public struct RegisterEventError: Error {
    public let serverStatusResponse: ServerStatusResponse
}

public struct NumberOfRegistrationOverError: Error {
    public let numberOfRegistrationOverResponse: ServerStatusResponse
}

public struct UnRegisterEventError: Error {
    public let unRegisterEventStatus: UnRegisterEventStatus
}

public struct ReleaseError: Error {
    public let occupyStatus: OccupyStatus
}

public struct CancelChangeShortageError: Error {}
public struct StartServerError: Error {}

public struct StatusError: Error {
    public let error: Error?
    public let statusCode: StatusCode?
}

public struct IncompleteTransactionError: Error {}


public struct NotConnectedError: Error {
    public init() {}
}

public struct EventError: Error {
    public let errorCode: String?
}

public struct ExclusiveError: Error {
    public let responseResult: ResponseResult?
    public let message: String?
}

public struct OtherError: Error {
    public let responseResult: ResponseResult?
    public let message: String?
}

public struct ApiParseError: Error {
    static let code = 999
    
    let error: Error
    let httpUrlResponse: HTTPURLResponse
    let data: Data?
    
    var localizedDescription: String {
        return error.localizedDescription
    }
}

public struct XMLParseError: Error {
    static let code = 999
    let data: Data?
}

public struct HttpUrlResponseError: Error {
    let error: Error?
    let response: URLResponse?
}
