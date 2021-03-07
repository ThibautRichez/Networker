//
//  NetworkerSessionConfigurationRepository.swift
//  
//
//  Created by RICHEZ Thibaut on 3/1/21.
//

import Foundation

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
// investigate this - doesn't seems right.
// how can we use this object outside of the package scope ???
// shared instance ?
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
        let headers: [String: String]? = self.value(forKey: .headers)
        return .init(token: token, baseURL: baseURL, headers: headers)
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
