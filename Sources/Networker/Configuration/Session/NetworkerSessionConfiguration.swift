//
//  NetworkerSessionConfiguration.swift
//  
//
//  Created by RICHEZ Thibaut on 10/24/20.
//

import Foundation

public struct NetworkerSessionConfiguration {
    public var token: String?
    public var baseURL: String?
    public var headers: [String: String]?

    public init(token: String? = nil,
                baseURL: String? = nil,
                headers: [String : String]? = nil) {
        self.token = token
        self.baseURL = baseURL
        self.headers = headers
    }
}

public enum NetworkerSessionConfigurationKey: String {
    case token = "networker.session.token"
    case baseURL = "netwoker.session.baseURL"
    case headers = "netwoker.session.headers"
}
