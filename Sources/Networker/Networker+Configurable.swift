//
//  Networker+Configurable.swift
//  
//
//  Created by RICHEZ Thibaut on 10/25/20.
//

import Foundation

protocol NetworkConfigurable {
    mutating func setBaseURL(to url: String?)
    mutating func setToken(to token: String?)
}

extension Networker: NetworkConfigurable {
    mutating func setBaseURL(to url: String?) {
        self.configuration.baseURL = url
    }

    mutating func setToken(to token: String?) {
        self.configuration.token = token
    }
}
