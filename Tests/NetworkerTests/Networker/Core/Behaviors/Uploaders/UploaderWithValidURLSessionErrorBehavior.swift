//
//  UploaderWithValidURLSessionErrorBehavior.swift
//  
//
//  Created by RICHEZ Thibaut on 10/27/20.
//

import Foundation
import Quick
import Nimble
@testable import Networker

struct UploaderWithValidURLSessionErrorBehaviorContext {
    var expectedError: NetworkerError
    var path: String
    var type: NetworkUploaderType = .post
    var data: Data?
    var expectedRequestURL: String
    var expectedErrorExecutorReturn: URLSessionTaskMock
    var session: URLSessionMock
    var sut: Networker
}

final class UploaderWithValidURLSessionErrorBehavior: Behavior<UploaderWithValidURLSessionErrorBehaviorContext> {
    override class func spec(_ aContext: @escaping () -> UploaderWithValidURLSessionErrorBehaviorContext) {
        describe("GIVEN a valid path and a context that produce an error") {
            var expectedError: NetworkerError!
            var path: String!
            var type: NetworkUploaderType!
            var data: Data!
            var expectedRequestURL: String!
            var expectedErrorExecutorReturn: URLSessionTaskMock!
            var session: URLSessionMock!
            var sut: Networker!
            beforeEach {
                expectedError = aContext().expectedError
                path = aContext().path
                type = aContext().type
                data = aContext().data
                expectedRequestURL = aContext().expectedRequestURL
                expectedErrorExecutorReturn = aContext().expectedErrorExecutorReturn
                session = aContext().session
                sut = aContext().sut
            }

            context("WHEN we execute the method") {
                var task: URLSessionTaskMock?
                var error: NetworkerError?

                beforeEach {
                    waitUntil { (done) in
                        task = sut.uploadError(path: path, type: type, data: data) { sutError in
                            error = sutError
                            done()
                        }
                    }
                }

                it("THEN the session request should be called and we should have the expected error") {
                    expect(error).to(matchError(expectedError))

                    expect(task).to(be(expectedErrorExecutorReturn))
                    expect(task?.resumeCallCount).to(equal(1))
                    expect(task?.didCallCancel).to(beFalse())

                    expect(session.uploadCallCount).to(equal(1))
                    expect(session.uploadArguments.count).to(equal(1))
                    let requestURL = try! sut.makeURL(from: path)
                    expect(requestURL).to(equal(URL(string: expectedRequestURL)))
                    expect(session.uploadArguments.first?.request).to(
                        equal(sut.makeURLRequest(for: .get, with: requestURL))
                    )
                    expect(session.uploadArguments.first?.data).to(equal(data))

                    expect(session.didCallRequest).to(beFalse())
                    expect(session.didCallDownload).to(beFalse())
                    expect(session.didCallGetTasks).to(beFalse())
                }
            }
        }
    }
}
