//
//  Errors.swift
//  GloryFramework
//
//  Created by John Kricorian on 06/12/2021.
//

import Foundation

public struct NetworkRequestError: Error {
    let error: Error?
    
    var localizedDescription: String {
        return error?.localizedDescription ?? "Network request error - no other information"
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

public struct FormatError: Error {

}

public struct AdjustTimeError: Error {
}

public struct StatusError: Error {
    public let error: Error?
    public let status: Status?
    public let statusCode: String?
}

public struct IsOccupiedError: Error {
    
}

public struct IncompleteTransactionError: Error {
    public let voucher: String
}

public struct NotConnectedError: Error {
    public let statusCode: StatusCode?
    public let message: String?
}

public struct EventError: Error {
    public let errorCode: String?
}


public struct ExclusiveError: Error {
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
    
    let error: Error?
    let httpUrlResponse: HTTPURLResponse
    let data: Data?
}
