//
//  NetworkerResponseValidatorTests.swift
//  
//
//  Created by RICHEZ Thibaut on 3/8/21.
//

import Foundation
import XCTest
@testable import Networker

final class NetworkerResponseValidatorTests: XCTestCase {
    private var response: HTTPURLResponse!

    private enum Error: Swift.Error {
        case example
    }

    override func setUp() {
        self.response = HTTPURLResponse()
    }

    override func tearDown() {
        self.response = nil
    }


    func test_GivenAnyValidatorThatReturnsTrue_WhenAppliedToResponse_ThenItShouldNotThrow() throws {
        try [
            NetworkerResponseValidator.statusCode({ _ in return true }),
            .mimeTypes({ _ in return true }),
            .headerFields({ _ in return true }),
            .expectedContentLength({ _ in return true }),
            .suggestedFilename({ _ in return true }),
            .textEncodingName({ _ in return true }),
            .url({ _ in return true }),
            .custom({ _ in return true })
        ].forEach { validator in
            XCTAssertNoThrow(try self.response.validate(using: [validator]))
        }
    }

    func test_GivenAnyValidatorThatReturnsFalse_WhenAppliedToResponse_ThenItShouldThrowAssociatedError() throws {
        try [
            NetworkerResponseValidator.statusCode({ _ in return false }),
            .mimeTypes({ _ in return false }),
            .headerFields({ _ in return false }),
            .expectedContentLength({ _ in return false }),
            .suggestedFilename({ _ in return false }),
            .textEncodingName({ _ in return false }),
            .url({ _ in return false }),
            .custom({ _ in return false })
        ].forEach { validator in
            XCTAssertThrowsError(try self.response.validate(using: [validator]), error: validator.associatedError(with: self.response))
        }
    }

    func test_GivenAnyValidatorThatThrows_WhenAppliedToResponse_ThenItShouldThrowCustomError() throws {
        try [
            NetworkerResponseValidator.statusCode({ _ in throw Error.example }),
            .mimeTypes({ _ in throw Error.example }),
            .headerFields({ _ in throw Error.example }),
            .expectedContentLength({ _ in throw Error.example }),
            .suggestedFilename({ _ in throw Error.example }),
            .textEncodingName({ _ in throw Error.example }),
            .url({ _ in throw Error.example }),
            .custom({ _ in throw Error.example })
        ].forEach { validator in
            XCTAssertThrowsError(try self.response.validate(using: [validator]), error: NetworkerResponseValidatorError.custom(Error.example, self.response))
        }
    }
}

private extension NetworkerResponseValidator {
    func associatedError(with response: HTTPURLResponse) -> NetworkerResponseValidatorError {
        switch self {
        case .statusCode(_):
            return .statusCode(response)
        case .mimeTypes(_):
            return .invalidMimeType(response)
        case .headerFields(_):
            return .invalidHeaders(response)
        case .expectedContentLength(_):
            return .invalidExpectedContentLength(response)
        case .suggestedFilename(_):
            return .invalidSuggestedFilename(response)
        case .textEncodingName(_):
            return .invalidTextEncodingName(response)
        case .url(_):
            return .invalidURL(response)
        case .custom(_):
            return .custom(nil, response)
        }
    }
}
