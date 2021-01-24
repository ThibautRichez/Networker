//
//  Networker+Configurable.swift
//  
//
//  Created by RICHEZ Thibaut on 10/25/20.
//

import Foundation

public protocol NetworkConfigurable {
    mutating func set(baseURL: String?)
    mutating func set(token: String?)
}

extension Networker: NetworkConfigurable {
    mutating public func set(baseURL: String?) {
        self.configuration.baseURL = baseURL
    }

    mutating public func set(token: String?) {
        self.configuration.token = token
    }
}
