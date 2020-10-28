//
//  NetworkerWithPathErrorBehavior.swift
//  
//
//  Created by RICHEZ Thibaut on 10/27/20.
//

import Foundation
import Quick
import Nimble
@testable import Networker

struct NetworkerWithPathErrorBehaviorContext {
    var path: String
    var expectedError: NetworkerError
    var session: URLSessionMock
    var queues: NetworkerQueuesMock
    var errorExecutor: ((String, @escaping (NetworkerError?) -> Void) ->URLSessionTaskMock?)
}

final class NetworkerWithPathErrorBehavior: Behavior<NetworkerWithPathErrorBehaviorContext> {
    override class func spec(_ aContext: @escaping () -> NetworkerWithPathErrorBehaviorContext) {
        describe("GIVEN an invalid path, the error it should produce and the executor") {
            var path: String!
            var expectedError: NetworkerError!
            var session: URLSessionMock!
            var queues: NetworkerQueuesMock!
            var errorExecutor: ((String, @escaping (NetworkerError?) -> Void) ->URLSessionTaskMock?)!
            beforeEach {
                path = aContext().path
                expectedError = aContext().expectedError
                session = aContext().session
                queues = aContext().queues
                errorExecutor = aContext().errorExecutor
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

                it("THEN the session methods should not be called and we should have the expected error") {
                    expect(error).to(matchError(expectedError))

                    expect(task).to(beNil())

                    expect(session.didCallUpload).to(beFalse())
                    expect(session.didCallRequest).to(beFalse())
                    expect(session.didCallDownload).to(beFalse())
                    expect(session.didCallGetTasks).to(beFalse())

                    expect(queues.asyncCallbackCallCount).to(equal(1))
                    expect(queues.didCallAddOperation).to(beFalse())
                    expect(queues.didCallCancelAllOperations).to(beFalse())
                }
            }
        }
    }
}
