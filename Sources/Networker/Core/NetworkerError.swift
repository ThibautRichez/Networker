//
//  NetworkerError.swift
//  
//
//  Created by RICHEZ Thibaut on 10/24/20.
//

import Foundation

public enum NetworkerError: Error {
    case path(NetworkerPathError)
    case remote(NetworkerRemoteError)
    case response(NetworkerResponseError)
    case noData
    case download(NetworkerDownloadError)
    case decoder(Error)
    case encoder(Error)
    case unknown(Error)
}

public enum NetworkerPathError: Error {
    /// Indicates that a request with a non-absolute path occured without
    /// a baseURL set either in the `NetworkerConfiguration` or
    /// `NetworkerSessionConfiguration`
    case baseURLMissing

    /// Indicates that the provided baseURL string representation is invalid.
    /// (fail to create an `URL` type)
    case invalidBaseURL(String)

    /// Indicates that a request with an invalid absolute path occured.
    case invalidAbsolutePath(String)

    /// Indicates that a request with an invalid relative path occured.
    case invalidRelativePath(String)
}


public enum NetworkerRemoteError: Error {
    case cancelled
    case connectionLost
    case notConnectedToInternet
    case appTransportSecurity
    case other(Error)

    init(_ error: Error) {
        let nsError = error as NSError
        switch (nsError.code, nsError.domain) {
        case (NSURLErrorCancelled, NSURLErrorDomain):
            self = .cancelled
        case (NSURLErrorNetworkConnectionLost, _):
            self = .connectionLost
        case (NSURLErrorNotConnectedToInternet, _):
            self = .notConnectedToInternet
        case (NSURLErrorAppTransportSecurityRequiresSecureConnection, _):
            self = .appTransportSecurity
        default:
            self = .other(error)
        }
    }
}

public enum NetworkerResponseError: Error {
    case empty
    case invalid(URLResponse)
    case statusCode(HTTPURLResponse)
    case invalidMimeType(got: String?, allowed: [String])
}

public enum NetworkerDownloadError: Error {
    case fileURLMissing
}
