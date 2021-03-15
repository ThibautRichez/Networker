//
//  File.swift
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

    func getHTTPResponse(error: Error?,
                         urlResponse: URLResponse?,
                         validators: [NetworkerResponseValidator]?) throws -> HTTPURLResponse {
        if let error = error {
            throw NetworkerError.remote(.init(error))
        }

        guard let response = urlResponse else {
            throw NetworkerError.response(.empty)
        }

        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkerError.response(.invalid(response))
        }

        try self.validate(httpResponse, with: validators)
        return httpResponse
    }
}

private extension Networker {
    /// - Note: If neither the `NetworkerConfiguration` nor the specific request contains
    /// a `NetworkerResponseValidator.statusCode` validator, a default one is used
    /// (cf. `NetworkerResponseValidator.defaultStatusCodeValidator`). Otherwise it would
    /// always be up to the user to specify a custom `.statusCode` which is most of the time
    /// redundant accross all codebase (except to handle uncommon cases)
    ///
    /// The `NetworkerConfiguration` validators are checked first. Thus, configuration
    /// validators errors will be returned before any specific request validators could be
    /// checked
    func validate(_ response: HTTPURLResponse, with validators: [NetworkerResponseValidator]?) throws {
        do {
            let configurationValidators = self.configuration?.responseValidators
            if (configurationValidators == nil || !configurationValidators!.containsStatusCode),
               (validators == nil || !validators!.containsStatusCode) {
                try response.validate(using: [.defaultStatusCodeValidator])
            }
            try response.validate(using: configurationValidators)
            try response.validate(using: validators)
        } catch let error as NetworkerResponseValidatorError {
            throw NetworkerError.response(.validator(error))
        } catch {
            throw NetworkerError.unknown(error)
        }
    }
}
