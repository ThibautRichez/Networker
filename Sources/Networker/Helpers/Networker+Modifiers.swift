//
//  Networker+Modifiers.swift
//  
//
//  Created by RICHEZ Thibaut on 10/28/20.
//

import Foundation

extension Networker {
    /// - Note: The `NetworkerConfiguration` modifiers are applied first.
    /// Thus, if both modifiers arrays contains the same cases, the configuration
    /// ones will be overriden by the ones defined by the specific request call.
    func makeURLRequest(_ urlConvertible: URLConvertible,
                        method: HTTPMethod,
                        modifiers: [NetworkerRequestModifier]? = nil) throws -> URLRequest {
        let url = try urlConvertible.asURL(relativeTo: self.configuration?.baseURL)
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = method.rawValue
        urlRequest.apply(modifiers: self.configuration?.requestModifiers)
        urlRequest.apply(modifiers: modifiers)
        return urlRequest
    }
}
