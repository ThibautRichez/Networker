//
//  Networker+Configurable.swift
//  
//
//  Created by RICHEZ Thibaut on 10/25/20.
//

import Foundation

protocol NetworkConfigurable {
    mutating func set(baseURL: String?)
    mutating func set(token: String?)
}

extension Networker: NetworkConfigurable {
    mutating func set(baseURL: String?) {
        self.configuration.baseURL = baseURL
    }

    mutating func set(token: String?) {
        self.configuration.token = token
    }
}
