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
    func makeURLRequest(_ url: URL,
                        method: HTTPMethod,
                        modifiers: [NetworkerRequestModifier]? = nil) -> URLRequest {
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = method.rawValue
        urlRequest.apply(modifiers: self.configuration?.requestModifiers)
        urlRequest.apply(modifiers: modifiers)
        return urlRequest
    }

    /// - Note: If neither the `NetworkerConfiguration` or the specific request contains
    /// a `NetworkerResponseValidator.statusCode` validator, a default one is used
    /// (cf. `NetworkerResponseValidator.defaultStatusCodeValidator`). Otherwise it would
    /// always be up to the user to specify a custom `.statusCode` which is most of the time
    /// redundant accross all codebase (except to handle uncommon cases)
    ///
    /// The `NetworkerConfiguration` validators are checked first. Thus, configuration
    /// validators errors will be returned before any specific request validators could be
    /// checked
    func getHTTPResponse(from response: URLResponse?,
                         validators: [NetworkerResponseValidator]? = nil) throws -> HTTPURLResponse {
        guard let response = response else {
            throw NetworkerError.response(.empty)
        }

        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkerError.response(.invalid(response))
        }

        do {
            if self.configuration?.responseValidators.containsStatusCode == false,
               validators?.containsStatusCode == false {
                try httpResponse.validate(using: [.defaultStatusCodeValidator])
            }
            try httpResponse.validate(using: self.configuration?.responseValidators)
            try httpResponse.validate(using: validators)
            return httpResponse
        } catch let error as NetworkerResponseValidatorError {
            throw NetworkerError.response(.validator(error))
        } catch {
            throw NetworkerError.response(.validator(.custom(error, httpResponse)))
        }
    }

    func handleRemoteError(_ error: Error?) throws {
        guard let error = error else { return }

        throw NetworkerError.remote(.init(error))
    }
}
