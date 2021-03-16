//
//  URLConvertibleTests.swift
//  
//
//  Created by RICHEZ Thibaut on 3/15/21.
//

import Foundation
import XCTest
@testable import Networker

enum ErrorStub: Error {
    case invalid
}

final class URLConvertibleMock: URLConvertible {
    var asURLCallCount = 0
    var asURLArguments = [URLConvertible?]()
    var didCallAsURL: Bool {
        self.asURLCallCount > 0
    }
    var result: ((URLConvertible?) throws -> URL)

    init(result: (@escaping (URLConvertible?) throws -> URL)) {
        self.result = result
    }

    func asURL(relativeTo baseURL: URLConvertible?) throws -> URL {
        self.asURLCallCount += 1
        self.asURLArguments.append(baseURL)
        return try self.result(baseURL)
    }
}

final class URLConvertibleTests: XCTestCase {
    // MARK: - Invalid URL

    private var invalidURLRepresentations: [String] {
        ["", "@'ç", "coding is a game"]
    }

    func test_GivenInvalidURLRepresentationsWithoutBaseURL_WhenConvertedToURLs_ThenShouldThrowInvalidURLError() throws {
        let expectedError = { NetworkerError.invalidURL($0) }
        try self.invalidURLRepresentations.forEach {
            XCTAssertThrowsError(try $0.asURL(), error: expectedError($0))
        }
    }

    func test_GivenInvalidURLRepresentationsWithInvalidBaseURL_WhenConvertedToURLs_ThenShouldThrowInvalidURLError() throws {
        let invalidBaseURLError = ErrorStub.invalid
        let invalidBaseURL = URLConvertibleMock(result: { _ in throw invalidBaseURLError })
        let expectedError = { NetworkerError.invalidURL($0) }
        try self.invalidURLRepresentations.forEach {
            XCTAssertThrowsError(try $0.asURL(relativeTo: invalidBaseURL), error: expectedError($0))
        }
    }

    func test_GivenInvalidURLRepresentationsWithValidBaseURL_WhenConvertedToURLs_ThenShouldThrowInvalidURLError() throws {
        let validBaseURL = URLConvertibleMock(result: { _ in
            return URL(string: "https://api.com")!
        })
        let expectedError = { NetworkerError.invalidURL($0) }
        try self.invalidURLRepresentations.forEach {
            XCTAssertThrowsError(try $0.asURL(relativeTo: validBaseURL), error: expectedError($0))
        }
    }

    // MARK: - Valid URL

    private var validURLRepresentations: [String] {
        ["https://valid-url.com", "getPage?pagename=home"]
    }

    func test_GivenValidURLRepresentationsURLsAndComponentsWithoutBaseURL_WhenConvertedToURLs_ThenURLsShouldMatch() throws {
        try self.validURLRepresentations.forEach { urlRepresentation in
            let url = URL(string: urlRepresentation)!
            let components = URLComponents(string: urlRepresentation)!

            XCTAssertEqual(try urlRepresentation.asURL().absoluteString, urlRepresentation)
            XCTAssertEqual(try url.asURL().absoluteString, urlRepresentation)
            XCTAssertEqual(try components.asURL().absoluteString, urlRepresentation)
        }
    }

    func test_GivenValidURLRepresentationsURLsAndComponentsWithInvalidBaseURL_WhenConvertedToURLs_ThenShouldThrowBaseURLError() throws {
        let invalidBaseURLError = ErrorStub.invalid
        let invalidBaseURL = URLConvertibleMock(result: { _ in throw invalidBaseURLError })
        try self.validURLRepresentations.forEach { urlRepresentation in
            let url = URL(string: urlRepresentation)!
            let components = URLComponents(string: urlRepresentation)!

            XCTAssertThrowsError(try urlRepresentation.asURL(relativeTo: invalidBaseURL), error: invalidBaseURLError)
            XCTAssertThrowsError(try url.asURL(relativeTo: invalidBaseURL), error: invalidBaseURLError)
            XCTAssertThrowsError(try components.asURL(relativeTo: invalidBaseURL), error: invalidBaseURLError)
        }
    }

    func test_GivenValidURLRepresentationsURLsAndComponentsWithValidBaseURL_WhenConvertedToURLs_ThenShouldReturnURLRelativeToBaseURL() throws {
        let validBaseURLRepresentation = "https://api.company.com/"
        let validBaseURL = URLConvertibleMock(result: { _ in
            return URL(string: validBaseURLRepresentation)!
        })

        try self.validURLRepresentations.forEach { urlRepresentation in
            let expectedResult = { URL(string: urlRepresentation, relativeTo: URL(string: validBaseURLRepresentation)) }
            let url = URL(string: urlRepresentation)!
            let components = URLComponents(string: urlRepresentation)!

            XCTAssertEqual(try urlRepresentation.asURL(relativeTo: validBaseURL), expectedResult())
            XCTAssertEqual(try url.asURL(relativeTo: validBaseURL), expectedResult())
            XCTAssertEqual(try components.asURL(relativeTo: validBaseURL), expectedResult())
        }
    }
}
