//
//  NetworkerRequestModifier.swift
//  
//
//  Created by RICHEZ Thibaut on 3/1/21.
//

import Foundation

public enum NetworkerRequestModifier {
    case cachePolicy(NetworkerCachePolicy)
    case headers([String: String])
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

    static let cellularAccess = NetworkerRequestAuthorizations(rawValue: 1 << 0)
    static let expensiveNetworkAccess = NetworkerRequestAuthorizations(rawValue: 1 << 1)
    static let constrainedNetworkAccess = NetworkerRequestAuthorizations(rawValue: 1 << 2)
    static let cookies = NetworkerRequestAuthorizations(rawValue: 1 << 3)
    static let pipelining = NetworkerRequestAuthorizations(rawValue: 1 << 4)

    static let all: NetworkerRequestAuthorizations = [
        .cellularAccess,
        .expensiveNetworkAccess,
        .constrainedNetworkAccess,
        .cookies
    ]
}
