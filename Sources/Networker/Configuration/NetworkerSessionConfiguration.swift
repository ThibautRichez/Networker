//
//  NetworkerSessionConfiguration.swift
//  
//
//  Created by RICHEZ Thibaut on 10/24/20.
//

import Foundation

public struct NetworkerSessionConfiguration {
    var token: String?
    var baseURL: String?
}

public enum NetworkerSessionConfigurationKey: String {
    case token = "Networker.token"
    case baseURL = "Netwoker.baseURL"
}

public protocol NetworkerSessionConfigurationWritter {
    func setValue(value: Any?, forKey key: NetworkerSessionConfigurationKey)
}

public protocol NetworkerSessionConfigurationReader {
    var configuration: NetworkerSessionConfiguration { get }
}

public protocol NetworkerSessionConfigurationValueReader {
    func value<T>(forKey key: NetworkerSessionConfigurationKey,
                  default defaultValue: @autoclosure () -> T) -> T
    func value<T>(forKey key: NetworkerSessionConfigurationKey) -> T?
}

public typealias NetworkerSessionConfigurationRepositoryProtocol = NetworkerSessionConfigurationReader & NetworkerSessionConfigurationValueReader & NetworkerSessionConfigurationWritter

public struct NetworkerSessionConfigurationRepository {
    var defaults: UserDefaults

    public init(defaults: UserDefaults = .networker()) {
        self.defaults = defaults
    }
}

// MARK: - NetworkerConfigurationRepository

extension NetworkerSessionConfigurationRepository: NetworkerSessionConfigurationRepositoryProtocol {
    // MARK: NetworkerConfigurationReader

    public var configuration: NetworkerSessionConfiguration {
        let token: String? = self.value(forKey: .token)
        let baseURL: String? = self.value(forKey: .baseURL)
        return .init(token: token, baseURL: baseURL)
    }

    // MARK: NetworkerSessionConfigurationValueReader

    public func value<T>(forKey key: NetworkerSessionConfigurationKey,
                  default defaultValue: @autoclosure () -> T) -> T {
        self.value(forKey: key) ?? defaultValue()
    }

    public func value<T>(forKey key: NetworkerSessionConfigurationKey) -> T? {
        self.defaults.value(forKey: key.rawValue) as? T
    }

    // MARK: NetworkerConfigurationWritter

    public func setValue(value: Any?,
                         forKey key: NetworkerSessionConfigurationKey) {
        self.defaults.setValue(value, forKey: key.rawValue)
    }
}
