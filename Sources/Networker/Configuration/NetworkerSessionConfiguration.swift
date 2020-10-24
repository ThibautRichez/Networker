//
//  NetworkerSessionConfiguration.swift
//  
//
//  Created by RICHEZ Thibaut on 10/24/20.
//

import Foundation

struct NetworkerSessionConfiguration {
    var token: String?
    var baseURL: String?
}

enum NetworkerSessionConfigurationKey: String {
    case token = "Networker.token"
    case baseURL = "Netwoker.baseURL"
}

protocol NetworkerSessionConfigurationWritter {
    func setValue(value: Any?, forKey key: NetworkerSessionConfigurationKey)
}

protocol NetworkerSessionConfigurationReader {
    var configuration: NetworkerSessionConfiguration { get }
}

protocol NetworkerSessionConfigurationValueReader {
    func value<T>(forKey key: NetworkerSessionConfigurationKey,
                  default defaultValue: @autoclosure () -> T) -> T
    func value<T>(forKey key: NetworkerSessionConfigurationKey) -> T?
}

typealias NetworkerSessionConfigurationRepositoryProtocol = NetworkerSessionConfigurationReader & NetworkerSessionConfigurationValueReader & NetworkerSessionConfigurationWritter

struct NetworkerSessionConfigurationRepository {
    static let shared: NetworkerSessionConfigurationRepositoryProtocol = {
        let defaults = UserDefaults(suiteName: "networker.session.configuration") ?? .standard
        return NetworkerSessionConfigurationRepository(defaults: defaults)
    }()

    var defaults: UserDefaults = .standard
}

// MARK: - NetworkerConfigurationRepository

extension NetworkerSessionConfigurationRepository: NetworkerSessionConfigurationRepositoryProtocol {
    // MARK: NetworkerConfigurationReader

    var configuration: NetworkerSessionConfiguration {
        let token: String? = self.value(forKey: .token)
        let baseURL: String? = self.value(forKey: .baseURL)
        return .init(token: token, baseURL: baseURL)
    }

    // MARK: NetworkerSessionConfigurationValueReader

    func value<T>(forKey key: NetworkerSessionConfigurationKey,
                  default defaultValue: @autoclosure () -> T) -> T {
        self.value(forKey: key) ?? defaultValue()
    }

    func value<T>(forKey key: NetworkerSessionConfigurationKey) -> T? {
        self.defaults.value(forKey: key.rawValue) as? T
    }

    // MARK: NetworkerConfigurationWritter

    func setValue(value: Any?, forKey key: NetworkerSessionConfigurationKey) {
        self.defaults.setValue(value, forKey: key.rawValue)
    }
}
