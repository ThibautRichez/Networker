//
//  RequesterWithValidURLSessionSuccessBehavior.swift
//  
//
//  Created by RICHEZ Thibaut on 10/27/20.
//

import Foundation
import Quick
import Nimble
@testable import Networker

struct RequesterWithValidURLSessionSuccessBehaviorContext {
    var expectedResult: NetworkRequesterResult
    var path: String
    var expectedRequestURL: String
    var expectedErrorExecutorReturn: URLSessionTaskMock
    var session: URLSessionMock
    var queues: NetworkerQueuesMock
    var sut: Networker
}

final class RequesterWithValidURLSessionSuccessBehavior: Behavior<RequesterWithValidURLSessionSuccessBehaviorContext> {
    override class func spec(_ aContext: @escaping () -> RequesterWithValidURLSessionSuccessBehaviorContext) {
        describe("GIVEN a valid path and a context that produce an error") {
            var expectedResult: NetworkRequesterResult!
            var path: String!
            var expectedRequestURL: String!
            var expectedErrorExecutorReturn: URLSessionTaskMock!
            var session: URLSessionMock!
            var queues: NetworkerQueuesMock!
            var sut: Networker!
            beforeEach {
                expectedResult = aContext().expectedResult
                path = aContext().path
                expectedRequestURL = aContext().expectedRequestURL
                expectedErrorExecutorReturn = aContext().expectedErrorExecutorReturn
                session = aContext().session
                queues = aContext().queues
                sut = aContext().sut
            }

            context("WHEN we call request") {
                var task: URLSessionTaskMock?
                var result: NetworkRequesterResult?

                beforeEach {
                    waitUntil { (done) in
                        task = sut.requestSuccess(path: path) { (sutResult) in
                            result = sutResult
                            done()
                        }
                    }
                }

                it("THEN it should return a valid result") {
                    expect(result).toNot(beNil())
                    expect(result?.data).to(equal(expectedResult.data))
                    expect(result?.statusCode).to(equal(expectedResult.statusCode))
                    expect(result?.headerFields.keys).to(equal(expectedResult.headerFields.keys))

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
