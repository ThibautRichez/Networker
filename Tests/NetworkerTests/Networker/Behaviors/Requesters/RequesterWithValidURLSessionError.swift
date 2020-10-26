//
//  RequesterWithValidURLSessionError.swift
//  
//
//  Created by RICHEZ Thibaut on 10/27/20.
//

import Foundation
import Quick
import Nimble
@testable import Networker

struct AnyRequesterErrorWithValidURLContext {
    var expectedError: NetworkerError
    var path: String
    var expectedRequestURL: String
    var expectedErrorExecutorReturn: URLSessionTaskMock
    var session: URLSessionMock
    var errorExecutor: ((String, @escaping (NetworkerError?) -> Void) ->URLSessionTaskMock?)
    var sut: Networker
}

final class RequesterWithValidURLSessionError: Behavior<AnyRequesterErrorWithValidURLContext> {
    override class func spec(_ aContext: @escaping () -> AnyRequesterErrorWithValidURLContext) {
        describe("GIVEN a valid path and a context that produce an error") {
            var path: String!
            var expectedRequestURL: String!
            var expectedError: NetworkerError!
            var expectedErrorExecutorReturn: URLSessionTaskMock!
            var session: URLSessionMock!
            var errorExecutor: ((String, @escaping (NetworkerError?) -> Void) ->URLSessionTaskMock?)!
            var sut: Networker!
            beforeEach {
                path = aContext().path
                expectedRequestURL = aContext().expectedRequestURL
                expectedError = aContext().expectedError
                expectedErrorExecutorReturn = aContext().expectedErrorExecutorReturn
                session = aContext().session
                errorExecutor = aContext().errorExecutor
                sut = aContext().sut
            }

            context("WHEN we execute the method") {
                var task: URLSessionTaskMock?
                var error: NetworkerError?

                beforeEach {
                    waitUntil { (done) in
                        task = errorExecutor(path, { executorError in
                            error = executorError
                            done()
                        })
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
                }
            }
        }
    }
}
