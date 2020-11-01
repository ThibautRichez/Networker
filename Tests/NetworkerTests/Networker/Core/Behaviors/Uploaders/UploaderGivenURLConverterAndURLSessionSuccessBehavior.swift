//
//  UploaderGivenURLConverterAndURLSessionSuccessBehavior.swift
//  
//
//  Created by RICHEZ Thibaut on 10/27/20.
//

import Foundation
import Quick
import Nimble
@testable import Networker

struct UploaderGivenURLConverterAndURLSessionSuccessContext {
    var expectedResult: NetworkUploaderResult
    var path: String
    var type: NetworkUploaderType = .post
    var data: Data?
    var expectedRequestURL: String
    var expectedTaskResult: URLSessionTaskMock
    var session: URLSessionMock
    var queues: NetworkerQueuesMock
    var sut: Networker
}

final class UploaderGivenURLConverterAndURLSessionSuccessBehavior: Behavior<UploaderGivenURLConverterAndURLSessionSuccessContext> {
    override class func spec(_ aContext: @escaping () -> UploaderGivenURLConverterAndURLSessionSuccessContext) {
        describe("GIVEN a valid path and a context that produce an error") {
            var expectedResult: NetworkUploaderResult!
            var path: String!
            var type: NetworkUploaderType!
            var data: Data!
            var expectedRequestURL: String!
            var expectedReturnTask: URLSessionTaskMock!
            var session: URLSessionMock!
            var queues: NetworkerQueuesMock!
            var sut: Networker!
            beforeEach {
                expectedResult = aContext().expectedResult
                path = aContext().path
                type = aContext().type
                data = aContext().data
                expectedRequestURL = aContext().expectedRequestURL
                expectedReturnTask = aContext().expectedTaskResult
                session = aContext().session
                queues = aContext().queues
                sut = aContext().sut
            }

            context("WHEN we execute the method") {
                var task: URLSessionTaskMock?
                var result: NetworkUploaderResult?
                
                beforeEach {
                    waitUntil { (done) in
                        task = sut.upload(
                            path: path,
                            type: type,
                            data: data,
                            completion: { (sutResult) in
                                result = try? sutResult.get()
                                done()
                            }) as? URLSessionTaskMock
                    }
                }

                it("THEN it should return a valid result") {
                    expect(result).toNot(beNil())
                    if expectedResult.data == nil {
                        expect(result?.data).to(beNil())
                    } else {
                        expect(result?.data).to(equal(expectedResult.data))
                    }

                    expect(result?.statusCode).to(equal(expectedResult.statusCode))
                    expect(result?.headerFields.keys).to(equal(expectedResult.headerFields.keys))

                    expect(task).to(be(expectedReturnTask))
                    expect(task?.resumeCallCount).to(equal(1))
                    expect(task?.didCallCancel).to(beFalse())

                    expect(session.uploadCallCount).to(equal(1))
                    expect(session.uploadArguments.count).to(equal(1))
                    let requestURL = try! sut.makeURL(from: path)
                    expect(requestURL).to(equal(URL(string: expectedRequestURL)))
                    expect(session.uploadArguments.first?.request).to(
                        equal(sut.makeURLRequest(for: type.requestType, with: requestURL))
                    )
                    expect(session.uploadArguments.first?.data).to(equal(data))

                    expect(session.didCallRequest).to(beFalse())
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
