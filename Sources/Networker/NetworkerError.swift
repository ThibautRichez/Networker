//
//  NetworkerError.swift
//  
//
//  Created by RICHEZ Thibaut on 10/24/20.
//

import Foundation

public enum NetworkerError: Error {
    case invalidURL(URLConvertible)
    case remote(NetworkerRemoteError)
    case response(NetworkerResponseError)
    case noData
    case download(NetworkerDownloadError)
    case decoder(Error)
    case encoder(Error)
    case unknown(Error)
}

public enum NetworkerRemoteError: Error {
    case cancelled(Error)
    case connectionLost(Error)
    case notConnectedToInternet(Error)
    case appTransportSecurity(Error)
    case other(Error)

    init(_ error: Error) {
        let nsError = error as NSError
        switch (nsError.code, nsError.domain) {
        case (NSURLErrorCancelled, NSURLErrorDomain):
            self = .cancelled(error)
        case (NSURLErrorNetworkConnectionLost, _):
            self = .connectionLost(error)
        case (NSURLErrorNotConnectedToInternet, _):
            self = .notConnectedToInternet(error)
        case (NSURLErrorAppTransportSecurityRequiresSecureConnection, _):
            self = .appTransportSecurity(error)
        default:
            self = .other(error)
        }
    }
}

public enum NetworkerResponseError: Error {
    case empty
    case emptyData(HTTPURLResponse)
    // Expect HTTPURLResponse -> http/https requests
    case invalid(URLResponse)
    case validator(NetworkerResponseValidatorError)
}

public enum NetworkerResponseValidatorError: Error {
    case statusCode(HTTPURLResponse)
    case invalidMimeType(HTTPURLResponse)
    case invalidHeaders(HTTPURLResponse)
    case invalidExpectedContentLength(HTTPURLResponse)
    case invalidSuggestedFilename(HTTPURLResponse)
    case invalidTextEncodingName(HTTPURLResponse)
    case invalidURL(HTTPURLResponse)
    case custom(Error?, HTTPURLResponse)
}

public enum NetworkerDownloadError: Error {
    case fileURLMissing
}
