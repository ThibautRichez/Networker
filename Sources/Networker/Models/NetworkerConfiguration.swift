//
//  NetworkerConfiguration.swift
//  
//
//  Created by RICHEZ Thibaut on 10/24/20.
//

import Foundation

/// Defines properties that will be applied on
/// each request made by the `Networker` instance.
public struct NetworkerConfiguration {
    /// URLs are constructed relatively to this property when
    /// using the APIs related to `URLConvertible` interface.
    public var baseURL: String?

    /// The modifiers to apply on each request.
    /// - Note: Those modifiers are applied before per request
    /// based modifiers.
    public var requestModifiers: [NetworkerRequestModifier]

    /// The validators to apply on each reponse.
    /// - Note: Those validators are checked before per request
    /// based validators.
    public var responseValidators: [NetworkerResponseValidator]

    public init(baseURL: String? = nil,
                requestModifiers: [NetworkerRequestModifier] = [],
                responseValidators: [NetworkerResponseValidator] = []) {
        self.baseURL = baseURL
        self.requestModifiers = requestModifiers
        self.responseValidators = responseValidators
    }
}
