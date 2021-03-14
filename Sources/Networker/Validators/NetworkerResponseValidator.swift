//
//  NetworkerResponseValidator.swift
//  
//
//  Created by RICHEZ Thibaut on 3/7/21.
//

import Foundation

/// Defines the validators that can be used in order
/// to checks that a specific `HTTPURLResponse` respect
/// a certain number of prerequisite
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

extension Array where Element == NetworkerResponseValidator {
    var containsStatusCode: Bool {
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
    case informational(Int)
    /// Further action must be taken in order to complete the request.
    case redirection(Int)
    /// The request contains incorrect syntax or cannot be fulfilled.
    case client(Int)
    /// The server failed to fulfill an apparently valid request.
    case server(Int)

    case unexpected(Int)
}

extension NetworkerResponseValidator {
    /// The status code validator to use if `NetworkerConfiguration` and per
    /// request based validators doesn't contained a custom one.
    /// cf. `Networker.getHTTPResponse(from:validators:)` for more details.
    static var defaultStatusCodeValidator: Self {
        .statusCode({ statusCode in
            switch statusCode {
            case 100...199:
                throw StatusCodeDefaultValidatorError.informational(statusCode)
            case 200...299:
                return true
            case 300...399:
                throw StatusCodeDefaultValidatorError.redirection(statusCode)
            case 400...499:
                throw StatusCodeDefaultValidatorError.client(statusCode)
            case 500...599:
                throw StatusCodeDefaultValidatorError.server(statusCode)
            default:
                throw StatusCodeDefaultValidatorError.unexpected(statusCode)
            }
        })
    }
}
