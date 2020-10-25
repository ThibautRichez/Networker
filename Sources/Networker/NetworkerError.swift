//
//  NetworkerError.swift
//  
//
//  Created by RICHEZ Thibaut on 10/24/20.
//

import Foundation

enum NetworkerError: Error {
    case path(NetworkerPathError)
    case remote(NetworkerRemoteError)
    case response(NetworkerResponseError)
    case noData
    case decoder(Error)
    case unknown(Error)
}

enum NetworkerPathError: Error {
    /// Indicates that a request with a non-absolute path occured without
    /// a baseURL set either in the `NetworkerConfiguration` or
    /// `NetworkerSessionConfiguration`
    case baseURLMissing

    /// Indicates that the provided baseURL string representation is invalid.
    /// (fail to create an `URL` type)
    case invalidBaseURL(String)

    /// Indicates that a request with an invalid absolute path occured.
    case invalidAbsolutePath(String)
}


enum NetworkerRemoteError: Error {
    case cancelled
    case connectionLost
    case notConnectedToInternet
    case appTransportSecurity
    case unknown(Error)

    init(_ error: Error) {
        let nsError = error as NSError
        if nsError.domain == NSURLErrorDomain, nsError.code == NSURLErrorCancelled {
            self = .cancelled
            return
        }

        switch nsError.code {
        case NSURLErrorNetworkConnectionLost:
            self = .connectionLost
        case NSURLErrorNotConnectedToInternet:
            self = .notConnectedToInternet
        case NSURLErrorAppTransportSecurityRequiresSecureConnection:
            self = .appTransportSecurity
        default:
            self = .unknown(error)
        }
    }
}

enum NetworkerResponseError: Error {
    case empty
    case invalid(URLResponse)
    case statusCode(HTTPURLResponse)
    case invalidMimeType(got: String?, allowed: [String])
}
