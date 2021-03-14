//
//  NetworkerRequestModifier.swift
//  
//
//  Created by RICHEZ Thibaut on 3/1/21.
//

import Foundation

/// Defines the modifiers that can be applied to an
/// `URLRequest`
///
/// Those can be defined for every request of a `Networker`
/// instance (cf. `NetworkerConfiguration`) or per request based.
public enum NetworkerRequestModifier {
    case timeoutInterval(TimeInterval)
    case cachePolicy(URLRequest.CachePolicy)
    case headers([String: String], override: Bool = false)
    case serviceType(URLRequest.NetworkServiceType)
    case authorizations(NetworkerRequestAuthorizations)
    case httpBody(Data?)
    case bodyStream(InputStream?)
    case mainDocumentURL(URL?)
    case custom((inout URLRequest) -> Void)
}

public struct NetworkerRequestAuthorizations: OptionSet {
    public let rawValue: Int

    public init(rawValue: Int) {
        self.rawValue = rawValue
    }

    /// (cf. `URLRequest.allowsCellularAccess`)
    static let cellularAccess = NetworkerRequestAuthorizations(rawValue: 1 << 0)

    /// - Note: Using this property will have an effect only on specific OS
    /// (cf. `URLRequest.allowsExpensiveNetworkAccess` restrictions)
    static let expensiveNetworkAccess = NetworkerRequestAuthorizations(rawValue: 1 << 1)

    /// - Note: Using this property will have an effect only on specific OS
    /// (cf. `URLRequest.allowsConstrainedNetworkAccess` restrictions)
    static let constrainedNetworkAccess = NetworkerRequestAuthorizations(rawValue: 1 << 2)

    /// (cf. `URLRequest.httpShouldHandleCookies`)
    static let cookies = NetworkerRequestAuthorizations(rawValue: 1 << 3)

    /// (cf. `URLRequest.httpShouldUsePipelining`)
    static let pipelining = NetworkerRequestAuthorizations(rawValue: 1 << 4)

    static let all: NetworkerRequestAuthorizations = [
        .cellularAccess,
        .expensiveNetworkAccess,
        .constrainedNetworkAccess,
        .cookies,
        .pipelining
    ]
}
