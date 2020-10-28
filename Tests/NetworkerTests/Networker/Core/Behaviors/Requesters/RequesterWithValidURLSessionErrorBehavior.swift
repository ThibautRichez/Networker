//
//  RequesterWithValidURLSessionErrorBehavior.swift
//  
//
//  Created by RICHEZ Thibaut on 10/27/20.
//

import Foundation
import Quick
import Nimble
@testable import Networker

struct RequesterWithValidURLSessionErrorBehaviorContext {
    var expectedError: NetworkerError
    var path: String
    var expectedRequestURL: String
    var expectedErrorExecutorReturn: URLSessionTaskMock
    var session: URLSessionMock
    var queues: NetworkerQueuesMock
    var sut: Networker
}

final class RequesterWithValidURLSessionErrorBehavior: Behavior<RequesterWithValidURLSessionErrorBehaviorContext> {
    override class func spec(_ aContext: @escaping () -> RequesterWithValidURLSessionErrorBehaviorContext) {
        describe("GIVEN a valid path and a context that produce an error") {
            var expectedError: NetworkerError!
            var path: String!
            var expectedRequestURL: String!
            var expectedErrorExecutorReturn: URLSessionTaskMock!
            var session: URLSessionMock!
            var queues: NetworkerQueuesMock!
            var sut: Networker!
            beforeEach {
                expectedError = aContext().expectedError
                path = aContext().path
                expectedRequestURL = aContext().expectedRequestURL
                expectedErrorExecutorReturn = aContext().expectedErrorExecutorReturn
                session = aContext().session
                queues = aContext().queues
                sut = aContext().sut
            }

            context("WHEN we execute the method") {
                var task: URLSessionTaskMock?
                var error: NetworkerError?

                beforeEach {
                    waitUntil { (done) in
                        task = sut.request(path: path) { (result) in
                            error = result.error
                            done()
                        } as? URLSessionTaskMock
                    }
                }

                it("THEN the session request should be called and we should have the expected error") {
                    expect(error).to(matchError(expectedError))

                    expect(task).to(be(expectedErrorExecutorReturn))
                    expect(task?.resumeCallCount).to(equal(1))
                    expect(task?.didCallCancel).to(beFalse())

                    expect(session.requestCallCount).to(equal(1))
                    expect(session.requestArguments.count).to(equal(1))
                    let requestURL = try! sut.makeURL(from: path)
                    expect(requestURL).to(equal(URL(string: expectedRequestURL)))
                    expect(session.requestArguments.first).to(
                        equal(sut.makeURLRequest(for: .get, with: requestURL))
                    )

                    expect(session.didCallUpload).to(beFalse())
                    expect(session.didCallDownload).to(beFalse())
                    expect(session.didCallGetTasks).to(beFalse())

                    expect(queues.asyncCallbackCallCount).to(equal(1))
                    expect(queues.addOperationCallCount).to(equal(1))
                    expect(queues.didCallCancelAllOperations).to(beFalse())
                }
            }
        }
    }
}
