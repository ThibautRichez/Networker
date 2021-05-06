//
//  NetworkerRemoteError.swift
//  
//
//  Created by RICHEZ Thibaut on 5/6/21.
//

import Foundation

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
