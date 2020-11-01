//
//  DownloaderGivenURLConverterAndURLSessionSuccessBehavior.swift
//  
//
//  Created by RICHEZ Thibaut on 10/31/20.
//

import Foundation
import Foundation
import Quick
import Nimble
@testable import Networker

struct DownloaderGivenURLConverterAndURLSessionSuccessContext {
    var expectedResult: NetworkDownloaderResult
    var path: String
    var expectedFileHandlerURL: URL
    var requestType: URLRequestType = .get
    var expectedRequestURL: String
    var expectedErrorExecutorReturn: URLSessionTaskMock
    var session: URLSessionMock
    var queues: NetworkerQueuesMock
    var sut: Networker
}

final class DownloaderGivenURLConverterAndURLSessionSuccessBehavior: Behavior<DownloaderGivenURLConverterAndURLSessionSuccessContext> {
    override class func spec(_ aContext: @escaping () -> DownloaderGivenURLConverterAndURLSessionSuccessContext) {
        describe("GIVEN a valid path and a context that produce an error") {
            var expectedResult: NetworkDownloaderResult!
            var path: String!
            var expectedFileHandlerURL: URL!
            var requestType: URLRequestType!
            var fileHandler: DownloaderFileHandlerMock!
            var expectedRequestURL: String!
            var expectedErrorExecutorReturn: URLSessionTaskMock!
            var session: URLSessionMock!
            var queues: NetworkerQueuesMock!
            var sut: Networker!
            beforeEach {
                let context = aContext()
                expectedResult = context.expectedResult
                path = context.path
                expectedFileHandlerURL = context.expectedFileHandlerURL
                requestType = context.requestType
                fileHandler = .init()
                expectedRequestURL = context.expectedRequestURL
                expectedErrorExecutorReturn = context.expectedErrorExecutorReturn
                session = context.session
                queues = context.queues
                sut = context.sut
            }

            context("WHEN we call download") {
                var task: URLSessionTaskMock?
                var result: NetworkDownloaderResult?

                beforeEach {
                    waitUntil { (done) in
                        task = sut.download(
                            path: path,
                            requestType: requestType,
                            fileHandler: fileHandler.handleFile(url:),
                            completion: { (sutResult) in
                                result = try? sutResult.get()
                                done()
                            }) as? URLSessionTaskMock
                    }
                }

                it("THEN it should return a valid result") {
                    expect(result).toNot(beNil())
                    expect(result?.statusCode).to(equal(expectedResult.statusCode))
                    expect(result?.headerFields.keys).to(equal(expectedResult.headerFields.keys))

                    expect(task).to(be(expectedErrorExecutorReturn))
                    expect(task?.resumeCallCount).to(equal(1))
                    expect(task?.didCallCancel).to(beFalse())

                    expect(session.downloadCallCount).to(equal(1))
                    expect(session.downloadArguments.count).to(equal(1))
                    let requestURL = try! sut.makeURL(from: path)
                    expect(requestURL).to(equal(URL(string: expectedRequestURL)))
                    expect(session.downloadArguments.first).to(
                        equal(sut.makeURLRequest(for: requestType, with: requestURL))
                    )
                    expect(fileHandler.handleFileCallCount).to(equal(1))
                    expect(fileHandler.handleFileArguments.count).to(equal(1))
                    expect(fileHandler.handleFileArguments.first).to(equal(expectedFileHandlerURL))

                    expect(session.didCallRequest).to(beFalse())
                    expect(session.didCallUpload).to(beFalse())
                    expect(session.didCallGetTasks).to(beFalse())

                    expect(queues.asyncCallbackCallCount).to(equal(1))
                    expect(queues.addOperationCallCount).to(equal(1))
                    expect(queues.didCallCancelAllOperations).to(beFalse())
                }
            }
        }
    }
}
