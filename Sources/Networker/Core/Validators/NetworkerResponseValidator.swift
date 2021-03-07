//
//  NetworkerResponseValidator.swift
//  
//
//  Created by RICHEZ Thibaut on 3/7/21.
//

import Foundation

public enum NetworkerResponseValidator {
    case statusCode((Int) throws -> Bool)
    case mimeTypes((String?) throws -> Bool)
    case headerFields(([AnyHashable: Any]) throws -> Bool)
    case expectedContentLength((Int64) throws -> Bool)
    case suggestedFilename((String?) throws -> Bool)
    case textEncodingName((String?) throws -> Bool)
    case url((URL?) throws -> Bool)
    case custom((HTTPURLResponse) throws -> Bool)
}

extension Optional where Wrapped == [NetworkerResponseValidator] {
    /// Appends a default `statusCode` validator if the current array
    /// does not already contains one.
    /// cf `NetworkerResponseValidator.defaultStatusCodeValidator`
    func appendingDefaultValidators() -> [NetworkerResponseValidator] {
        var validators = self ?? []
        if !validators.containsValidStatusCodes {
            validators.insert(.defaultStatusCodeValidator, at: 0)
        }
        return validators
    }
}

private extension Array where Element == NetworkerResponseValidator {
    var containsValidStatusCodes: Bool {
        self.contains { validator in
            if case .statusCode(_) = validator {
                return true
            }
            return false
        }
    }
}

enum StatusCodeDefaultValidatorError: Error {
    /// The request has been received and the process is continuing.
    case informational
    /// Further action must be taken in order to complete the request.
    case redirection
    /// The request contains incorrect syntax or cannot be fulfilled.
    case client
    /// The server failed to fulfill an apparently valid request.
    case server

    case unexpected
}

private extension NetworkerResponseValidator {
    static var defaultStatusCodeValidator: Self {
        .statusCode({ statusCode in
            switch statusCode {
            case 100...199:
                throw StatusCodeDefaultValidatorError.informational
            case 200...299:
                return true
            case 300...399:
                throw StatusCodeDefaultValidatorError.redirection
            case 400...499:
                throw StatusCodeDefaultValidatorError.client
            case 500...599:
                throw StatusCodeDefaultValidatorError.server
            default:
                throw StatusCodeDefaultValidatorError.unexpected
            }
        })
    }
}
