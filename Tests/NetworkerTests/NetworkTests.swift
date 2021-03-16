//
//  NetworkerRequesterTests.swift
//  
//
//  Created by RICHEZ Thibaut on 3/16/21.
//

import Foundation
import XCTest
@testable import Networker

final class NetworkerTests: XCTestCase {
    var session: URLSessionMock!
    var sut: Networker!

    override func setUp() {
        super.setUp()

        self.session = .init()
        self.sut = .init(session: self.session, configuration: .init(), queues: .init())
    }

    override func tearDown() {
        super.tearDown()

        self.session = nil
        self.sut = nil
    }

    func test_GivenURLConvertibleThatThrowsNetworkerError_WhenWeRequestUploadOrDownload_ThenItShouldCompleteWithSameError() {
        // GIVEN
        let networkerError = NetworkerError.invalidURL("")
        let url = URLConvertibleMock(result: { _ in throw networkerError })

        // WHEN
        let expectation = XCTestExpectation(description: "Request/Upload/Download completion")
        self.requestUploadDownload(url) { requestResult, uploadResult, downloadResult in
            // THEN
            XCTAssertEqual(requestResult.error, networkerError)
            XCTAssertEqual(uploadResult.error, networkerError)
            XCTAssertEqual(downloadResult.error, networkerError)
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 1)
    }

    func test_GivenURLConvertibleThatThrowsCustomError_WhenWeRequestUploadOrDownload_ThenItShouldCompleteWithUnknownError() {
        // GIVEN
        let networkerError = ErrorStub.invalid
        let url = URLConvertibleMock(result: { _ in throw networkerError })
        let expectedError: NetworkerError = .unknown(networkerError)

        // WHEN
        let expectation = XCTestExpectation(description: "Request/Upload/Download completion")
        self.requestUploadDownload(url) { requestResult, uploadResult, downloadResult in
            // THEN
            XCTAssertEqual(requestResult.error, expectedError)
            XCTAssertEqual(uploadResult.error, expectedError)
            XCTAssertEqual(downloadResult.error, expectedError)
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 1)
    }

    func test_GivenAnyURLConvertibleAndNilConfigurationBaseURL_WhenWeRequestUploadOrDownload_ThenItShouldCallURLConvertibleAsURLWithNilBaseURL() {
        // GIVEN
        let url = URLConvertibleMock(result: { _ in throw ErrorStub.invalid })
        self.sut.configuration?.baseURL = nil

        // WHEN
        let expectation = XCTestExpectation(description: "Request/Upload/Download completion")
        self.requestUploadDownload(url) { requestResult, uploadResult, downloadResult in
            // THEN
            XCTAssertEqual(url.asURLArguments.count, 3)
            XCTAssertNil(url.asURLArguments[0])
            XCTAssertNil(url.asURLArguments[1])
            XCTAssertNil(url.asURLArguments[2])
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 1)
    }

    func test_GivenAnyURLConvertibleAndConfigurationBaseURL_WhenWeRequestUploadOrDownload_ThenItShouldCallURLConvertibleAsURLWithBaseURL() {
        // GIVEN
        let url = URLConvertibleMock(result: { _ in throw ErrorStub.invalid })
        let baseURL = "https://api.company/"
        self.sut.configuration?.baseURL = baseURL

        // WHEN
        let expectation = XCTestExpectation(description: "Request/Upload/Download completion")
        self.requestUploadDownload(url) { requestResult, uploadResult, downloadResult in
            // THEN
            XCTAssertEqual(url.asURLArguments.count, 3)
            XCTAssertEqual(url.asURLArguments[0] as? String, baseURL)
            XCTAssertEqual(url.asURLArguments[1] as? String, baseURL)
            XCTAssertEqual(url.asURLArguments[2] as? String, baseURL)
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 1)
    }

    func test_GivenValidURLConvertibleAndHTTPMethods_WhenWeRequestUploadOrDownload_ThenItShouldCallURLSessionRequestWithSameHTTPMethod() {
        // GIVEN
        let url = URLConvertibleMock(result: { _ in URL(string: "https://api.company/")! })
        let httpMethods: [HTTPMethod] = [.connect, .delete, .get, .head, .options, .patch, .post, .put, .trace]

        self.session.requestResultCompletion = { completion in completion(nil, nil, nil) }
        self.session.uploadResultCompletion = { completion in completion(nil, nil, nil) }
        self.session.downloadResultCompletion = { completion in completion(nil, nil, nil) }

        // WHEN
        let group = DispatchGroup()
        httpMethods.forEach {
            group.enter()
            self.requestUploadDownload(url, method: $0) { _, _, _ in group.leave() }
        }

        // THEN
        let expectation = XCTestExpectation(description: "End of DispatchGroup")
        group.notify(queue: .main) {
            XCTAssertEqual(self.session.requestCallCount, httpMethods.count)
            XCTAssertEqual(self.session.uploadCallCount, httpMethods.count)
            XCTAssertEqual(self.session.downloadCallCount, httpMethods.count)
            httpMethods.enumerated().forEach { index, method in
                XCTAssertEqual(self.session.requestArguments[index].httpMethod, method.rawValue)
                XCTAssertEqual(self.session.uploadArguments[index].request.httpMethod, method.rawValue)
                XCTAssertEqual(self.session.downloadArguments[index].httpMethod, method.rawValue)
            }
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 1)
    }
}

private extension NetworkerTests {
    func requestUploadDownload(
        _ url: URLConvertible,
        method: HTTPMethod = .get,
        completion: @escaping ((Result<NetworkRequesterResult, NetworkerError>), Result<NetworkUploaderResult, NetworkerError>, Result<NetworkDownloaderResult, NetworkerError>) -> Void) {
        var requestResult: Result<NetworkRequesterResult, NetworkerError>?
        var uploadResult: Result<NetworkUploaderResult, NetworkerError>?
        var downloadResult: Result<NetworkDownloaderResult, NetworkerError>?
        let group = DispatchGroup()

        group.enter()
        self.sut.request(url, method: method) { result in
            requestResult = result
            group.leave()
        }

        group.enter()
        self.sut.upload(Data(), to: url, method: method) { result in
            uploadResult = result
            group.leave()
        }

        group.enter()
        self.sut.download(url, method: method, fileHandler: { _ in }) { result in
            downloadResult = result
            group.leave()
        }

        group.notify(queue: .main) {
            completion(requestResult!, uploadResult!, downloadResult!)
        }
    }
}
