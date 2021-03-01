//
//  NetworkerConfiguration.swift
//  
//
//  Created by RICHEZ Thibaut on 10/24/20.
//

import Foundation

public struct NetworkerConfiguration {
    public var baseURL: String?
    public var token: String?
    public var timeoutInterval: TimeInterval

    public init(baseURL: String? = nil,
                token: String? = nil,
                timeoutInterval: TimeInterval = 60) {
        self.baseURL = baseURL
        self.token = token
        self.timeoutInterval = timeoutInterval
    }
}
