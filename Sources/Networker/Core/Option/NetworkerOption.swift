//
//  NetworkerOption.swift
//  
//
//  Created by RICHEZ Thibaut on 3/1/21.
//

import Foundation

public enum NetworkerOption {
    case cachePolicy(NetworkerCachePolicy)
    case headers([String: String])
    case serviceType(URLRequest.NetworkServiceType)
    case authorizations(NetworkerAuthorizations)
}

public struct NetworkerAuthorizations: OptionSet {
    public let rawValue: Int

    public init(rawValue: Int) {
        self.rawValue = rawValue
    }

    static let cellularAccess = NetworkerAuthorizations(rawValue: 1 << 0)
    static let expensiveNetworkAccess = NetworkerAuthorizations(rawValue: 1 << 1)
    static let constrainedNetworkAccess = NetworkerAuthorizations(rawValue: 1 << 2)
    static let cookies = NetworkerAuthorizations(rawValue: 1 << 3)

    static let all: NetworkerAuthorizations = [
        .cellularAccess,
        .expensiveNetworkAccess,
        .constrainedNetworkAccess,
        .cookies
    ]
}
