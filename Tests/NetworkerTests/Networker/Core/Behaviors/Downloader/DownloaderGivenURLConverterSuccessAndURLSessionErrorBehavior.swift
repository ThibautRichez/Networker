//
//  DownloaderGivenURLConverterSuccessAndURLSessionErrorBehavior.swift
//  
//
//  Created by RICHEZ Thibaut on 10/31/20.
//

import Foundation
import Quick
import Nimble
@testable import Networker

struct DownloaderGivenURLConverterSuccessAndURLSessionErrorContext {
    var expectedError: NetworkerError
    var path: String
    var method: HTTPMethod = .get
    var expectedRequestURL: String
    var expectedTaskResult: URLSessionTaskMock
    var session: URLSessionMock
    var queues: NetworkerQueuesMock
    var sut: Networker
}

final class DownloaderGivenURLConverterSuccessAndURLSessionErrorBehavior: Behavior<DownloaderGivenURLConverterSuccessAndURLSessionErrorContext> {
    override class func spec(_ aContext: @escaping () -> DownloaderGivenURLConverterSuccessAndURLSessionErrorContext) {
        describe("GIVEN a valid path and a context that produce an error") {
            var expectedError: NetworkerError!
            var path: String!
            var method: HTTPMethod!
            var fileHandler: DownloaderFileHandlerMock!
            var expectedRequestURL: String!
            var expectedErrorExecutorReturn: URLSessionTaskMock!
            var session: URLSessionMock!
            var queues: NetworkerQueuesMock!
            var sut: Networker!
            beforeEach {
                let context = aContext()
                expectedError = context.expectedError
                path = context.path
                method = context.method
                fileHandler = .init()
                expectedRequestURL = context.expectedRequestURL
                expectedErrorExecutorReturn = context.expectedTaskResult
                session = context.session
                queues = context.queues
                sut = context.sut
            }

            context("WHEN we call download") {
                var task: URLSessionTaskMock?
                var error: NetworkerError?

                beforeEach {
                    waitUntil { (done) in
                        task = sut.download(
                            path,
                            method: method,
                            fileHandler: fileHandler.handleFile(url:),
                            completion: { (result) in
                                error = result.error
                                done()
                        }) as? URLSessionTaskMock
                    }
                }

                it("THEN the session request should be called and we should have the expected error") {
                    expect(error).to(matchError(expectedError))

                    expect(task).to(be(expectedErrorExecutorReturn))
                    expect(task?.resumeCallCount).to(equal(1))
                    expect(task?.didCallCancel).to(beFalse())


                    expect(session.downloadCallCount).to(equal(1))
                    expect(session.downloadArguments.count).to(equal(1))
                    let requestURL = try! sut.makeURL(from: path)
                    expect(requestURL).to(equal(URL(string: expectedRequestURL)))
                    expect(session.downloadArguments.first).to(
                        equal(sut.makeURLRequest(with: method, with: requestURL))
                    )
                    expect(fileHandler.didCallHandleFileCallCount).to(beFalse())

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
