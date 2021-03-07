//
//  HTTPURLResponse+NetworkerResponseValidator.swift
//  
//
//  Created by RICHEZ Thibaut on 3/7/21.
//

import Foundation

extension HTTPURLResponse {
    func validate(using validators: [NetworkerResponseValidator]) throws {
        try validators.forEach(self.validate(using:))
    }
}

private extension HTTPURLResponse {
    func validate(using validator: NetworkerResponseValidator) throws {
        switch validator {
        case .statusCode(let validator):
            try self.validate(self.statusCode, with: validator, throwError: .statusCode(self))
        case .mimeTypes(let validator):
            try self.validate(self.mimeType, with: validator, throwError: .invalidMimeType(self))
        case .headerFields(let validator):
            try self.validate(self.allHeaderFields, with: validator, throwError: .invalidHeaders(self))
        case .expectedContentLength(let validator):
            try self.validate(self.expectedContentLength, with: validator, throwError: .invalidExpectedContentLength(self))
        case .suggestedFilename(let validator):
            try self.validate(self.suggestedFilename, with: validator, throwError: .invalidSuggestedFilename(self))
        case .textEncodingName(let validator):
            try self.validate(self.textEncodingName, with: validator, throwError: .invalidTextEncodingName(self))
        case .url(let validator):
            try self.validate(self.url, with: validator, throwError: .invalidURL(self))
        case .custom(let validator):
            try self.validate(self, with: validator, throwError: .custom(nil, self))
        }
    }

    func validate<T>(_ element: T,
                     with validator: (T) throws -> Bool,
                     throwError error: NetworkerResponseValidatorError) throws {
        do {
            if !(try validator(element)) {
                throw error
            }
        } catch {
            throw NetworkerResponseValidatorError.custom(error, self)
        }
    }
}
