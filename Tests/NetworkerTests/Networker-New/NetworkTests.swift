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

    func test_GivenURLConvertibleThrowingNetworkerError_WhenWeRequestUploadOrDownload_ThenItShouldNotCallSessionAndCompleteWithThatError() {
        // GIVEN
        let networkerError = NetworkerError.invalidURL("")
        let url = URLConvertibleMock(result: { _ in throw networkerError })

        // WHEN
        let expectation = XCTestExpectation(description: "Request/Upload/Download completion")
        self.sut.requestUploadDownload(url) { requestResult, uploadResult, downloadResult in
            // THEN
            XCTAssertFalse(self.session.didCallRequest)
            XCTAssertFalse(self.session.didCallUpload)
            XCTAssertFalse(self.session.didCallDownload)
            XCTAssertFalse(self.session.didCallGetTasks)

            XCTAssertEqual(requestResult.error, networkerError)
            XCTAssertEqual(uploadResult.error, networkerError)
            XCTAssertEqual(downloadResult.error, networkerError)

            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 1)
    }

    func test_GivenURLConvertibleThrowingCustomError_WhenWeRequestUploadOrDownload_ThenItShouldNotCallSessionAndCompleteWithUnknownError() {
        // GIVEN
        let customError = ErrorStub.invalid
        let url = URLConvertibleMock(result: { _ in throw customError })

        // WHEN
        let expectation = XCTestExpectation(description: "Request/Upload/Download completion")
        self.sut.requestUploadDownload(url) { requestResult, uploadResult, downloadResult in
            // THEN
            XCTAssertFalse(self.session.didCallRequest)
            XCTAssertFalse(self.session.didCallUpload)
            XCTAssertFalse(self.session.didCallDownload)
            XCTAssertFalse(self.session.didCallGetTasks)

            let expectedError: NetworkerError = .unknown(customError)
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
        self.sut.requestUploadDownload(url) { requestResult, uploadResult, downloadResult in
            // THEN
            XCTAssertEqual(url.asURLArguments.count, 3)
            XCTAssertNil(url.asURLArguments[0])
            XCTAssertNil(url.asURLArguments[1])
            XCTAssertNil(url.asURLArguments[2])

            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 1)
    }

    func test_GivenAnyURLConvertibleAndConfigurationBaseURL_WhenWeRequestUploadOrDownload_ThenItShouldCallURLConvertibleAsURLWithThatURL() {
        // GIVEN
        let url = URLConvertibleMock(result: { _ in throw ErrorStub.invalid })
        let baseURL = "https://api.company/"
        self.sut.configuration?.baseURL = baseURL

        // WHEN
        let expectation = XCTestExpectation(description: "Request/Upload/Download completion")
        self.sut.requestUploadDownload(url) { requestResult, uploadResult, downloadResult in
            // THEN
            XCTAssertEqual(url.asURLArguments.count, 3)
            XCTAssertEqual(url.asURLArguments[0] as? String, baseURL)
            XCTAssertEqual(url.asURLArguments[1] as? String, baseURL)
            XCTAssertEqual(url.asURLArguments[2] as? String, baseURL)

            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 1)
    }

    func test_GivenValidURLConvertibleAndHTTPMethod_WhenWeRequestUploadOrDownload_ThenItShouldCallURLSessionMethodsWithURLRequestSetToThatHTTPMethod() {
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
            self.sut.requestUploadDownload(url, method: $0) { _, _, _ in group.leave() }
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

    func test_GivenValidURLConvertibleAndConfigurationRequestModifier_WhenWeRequestUploadOrDownload_ThenItShouldCallURLSessionMethodsWithURLRequestModifiedAccordingly() {
        // GIVEN
        let url = URLConvertibleMock(result: { _ in URL(string: "https://api.company/")! })
        let timeoutInterval: TimeInterval = 94
        self.sut.configuration?.requestModifiers = [.timeoutInterval(timeoutInterval)]

        self.session.requestResultCompletion = { completion in completion(nil, nil, nil) }
        self.session.uploadResultCompletion = { completion in completion(nil, nil, nil) }
        self.session.downloadResultCompletion = { completion in completion(nil, nil, nil) }

        // WHEN
        let expectation = XCTestExpectation(description: "Request/Upload/Download completion")
        self.sut.requestUploadDownload(url) { requestResult, uploadResult, downloadResult in
            // THEN
            XCTAssertEqual(self.session.requestCallCount, 1)
            XCTAssertEqual(self.session.requestArguments.first?.timeoutInterval, timeoutInterval)

            XCTAssertEqual(self.session.uploadCallCount, 1)
            XCTAssertEqual(self.session.uploadArguments.first?.request.timeoutInterval, timeoutInterval)

            XCTAssertEqual(self.session.downloadCallCount, 1)
            XCTAssertEqual(self.session.downloadArguments.first?.timeoutInterval, timeoutInterval)

            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 1)
    }

    func test_GivenValidURLConvertibleAndRequestModifierPassedThroughMethods_WhenWeRequestUploadOrDownload_ThenItShouldCallURLSessionMethodsWithURLRequestModifiedAccordingly() {
        // GIVEN
        let url = URLConvertibleMock(result: { _ in URL(string: "https://api.company/")! })
        let timeoutInterval: TimeInterval = 9
        let requestModifiers: [NetworkerRequestModifier] = [.timeoutInterval(timeoutInterval)]

        self.session.requestResultCompletion = { completion in completion(nil, nil, nil) }
        self.session.uploadResultCompletion = { completion in completion(nil, nil, nil) }
        self.session.downloadResultCompletion = { completion in completion(nil, nil, nil) }

        // WHEN
        let expectation = XCTestExpectation(description: "Request/Upload/Download completion")
        self.sut.requestUploadDownload(url, modifiers: requestModifiers) { requestResult, uploadResult, downloadResult in
            // THEN
            XCTAssertEqual(self.session.requestCallCount, 1)
            XCTAssertEqual(self.session.requestArguments.first?.timeoutInterval, timeoutInterval)

            XCTAssertEqual(self.session.uploadCallCount, 1)
            XCTAssertEqual(self.session.uploadArguments.first?.request.timeoutInterval, timeoutInterval)

            XCTAssertEqual(self.session.downloadCallCount, 1)
            XCTAssertEqual(self.session.downloadArguments.first?.timeoutInterval, timeoutInterval)

            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 1)
    }

    func test_GivenValidURLConvertibleAndSameRequestModifierPassedThroughMethodsAndConfiguration_WhenWeRequestUploadOrDownload_ThenItShouldCallURLSessionMethodsWithURLRequestModifiedWithValuePassedThroughMethods() {
        // GIVEN
        let url = URLConvertibleMock(result: { _ in URL(string: "https://api.company/")! })
        let configurationTimeoutInterval: TimeInterval = 1
        self.sut.configuration?.requestModifiers = [.timeoutInterval(configurationTimeoutInterval)]

        self.session.requestResultCompletion = { completion in completion(nil, nil, nil) }
        self.session.uploadResultCompletion = { completion in completion(nil, nil, nil) }
        self.session.downloadResultCompletion = { completion in completion(nil, nil, nil) }

        // WHEN
        let expectation = XCTestExpectation(description: "Request/Upload/Download completion")
        let timeoutInterval: TimeInterval = 94
        self.sut.requestUploadDownload(url, modifiers: [.timeoutInterval(timeoutInterval)]) { requestResult, uploadResult, downloadResult in
            // THEN
            XCTAssertEqual(self.session.requestCallCount, 1)
            XCTAssertEqual(self.session.requestArguments.first?.timeoutInterval, timeoutInterval)

            XCTAssertEqual(self.session.uploadCallCount, 1)
            XCTAssertEqual(self.session.uploadArguments.first?.request.timeoutInterval, timeoutInterval)

            XCTAssertEqual(self.session.downloadCallCount, 1)
            XCTAssertEqual(self.session.downloadArguments.first?.timeoutInterval, timeoutInterval)

            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 1)
    }

    func test_GivenValidURLConvertibleAndDifferentRequestModifierPassedThroughMethodsAndConfiguration_WhenWeRequestUploadOrDownload_ThenItShouldCallURLSessionMethodsWithURLRequestModifiedWithBothValues() {
        // GIVEN
        let url = URLConvertibleMock(result: { _ in URL(string: "https://api.company/")! })
        let timeoutInterval: TimeInterval = 1
        self.sut.configuration?.requestModifiers = [.timeoutInterval(timeoutInterval)]

        self.session.requestResultCompletion = { completion in completion(nil, nil, nil) }
        self.session.uploadResultCompletion = { completion in completion(nil, nil, nil) }
        self.session.downloadResultCompletion = { completion in completion(nil, nil, nil) }

        // WHEN
        let expectation = XCTestExpectation(description: "Request/Upload/Download completion")
        let serviceType: URLRequest.NetworkServiceType = .avStreaming
        self.sut.requestUploadDownload(url, modifiers: [.serviceType(serviceType)]) { requestResult, uploadResult, downloadResult in
            // THEN
            XCTAssertEqual(self.session.requestCallCount, 1)
            XCTAssertEqual(self.session.requestArguments.first?.timeoutInterval, timeoutInterval)
            XCTAssertEqual(self.session.requestArguments.first?.networkServiceType, serviceType)

            XCTAssertEqual(self.session.uploadCallCount, 1)
            XCTAssertEqual(self.session.uploadArguments.first?.request.timeoutInterval, timeoutInterval)
            XCTAssertEqual(self.session.uploadArguments.first?.request.networkServiceType, serviceType)

            XCTAssertEqual(self.session.downloadCallCount, 1)
            XCTAssertEqual(self.session.downloadArguments.first?.timeoutInterval, timeoutInterval)
            XCTAssertEqual(self.session.downloadArguments.first?.networkServiceType, serviceType)

            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 1)
    }
}

private extension Networker {
    func requestUploadDownload(
        _ url: URLConvertible,
        method: HTTPMethod = .get,
        modifiers: [NetworkerRequestModifier]? = nil,
        completion: @escaping ((Result<NetworkRequesterResult, NetworkerError>), Result<NetworkUploaderResult, NetworkerError>, Result<NetworkDownloaderResult, NetworkerError>) -> Void) {
        var requestResult: Result<NetworkRequesterResult, NetworkerError>?
        var uploadResult: Result<NetworkUploaderResult, NetworkerError>?
        var downloadResult: Result<NetworkDownloaderResult, NetworkerError>?
        let group = DispatchGroup()

        group.enter()
        self.request(url, method: method, requestModifiers: modifiers) { result in
            requestResult = result
            group.leave()
        }

        group.enter()
        self.upload(Data(), to: url, method: method, requestModifiers: modifiers) { result in
            uploadResult = result
            group.leave()
        }

        group.enter()
        self.download(url, method: method, fileHandler: { _ in }, requestModifiers: modifiers) { result in
            downloadResult = result
            group.leave()
        }

        group.notify(queue: .main) {
            completion(requestResult!, uploadResult!, downloadResult!)
        }
    }
}
