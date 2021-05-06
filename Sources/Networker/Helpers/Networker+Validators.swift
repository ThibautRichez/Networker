//
//  File.swift
//  
//
//  Created by RICHEZ Thibaut on 5/6/21.
//

import Foundation

extension Networker {
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
