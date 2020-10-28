//
//  UploaderWithValidURLSessionSuccessBehavior.swift
//  
//
//  Created by RICHEZ Thibaut on 10/27/20.
//

import Foundation
import Quick
import Nimble
@testable import Networker

struct UploaderWithValidURLSessionSuccessBehaviorContext {
    var expectedResult: NetworkUploaderResult
    var path: String
    var type: NetworkUploaderType = .post
    var data: Data?
    var expectedRequestURL: String
    var expectedReturnTask: URLSessionTaskMock
    var session: URLSessionMock
    var sut: Networker
}

final class UploaderWithValidURLSessionSuccessBehavior: Behavior<UploaderWithValidURLSessionSuccessBehaviorContext> {
    override class func spec(_ aContext: @escaping () -> UploaderWithValidURLSessionSuccessBehaviorContext) {
        describe("GIVEN a valid path and a context that produce an error") {
            var expectedResult: NetworkUploaderResult!
            var path: String!
            var type: NetworkUploaderType!
            var data: Data!
            var expectedRequestURL: String!
            var expectedReturnTask: URLSessionTaskMock!
            var session: URLSessionMock!
            var sut: Networker!
            beforeEach {
                expectedResult = aContext().expectedResult
                path = aContext().path
                type = aContext().type
                data = aContext().data
                expectedRequestURL = aContext().expectedRequestURL
                expectedReturnTask = aContext().expectedReturnTask
                session = aContext().session
                sut = aContext().sut
            }

            context("WHEN we execute the method") {
                var task: URLSessionTaskMock?
                var result: NetworkUploaderResult?

                beforeEach {
                    waitUntil { (done) in
                        task = sut.uploadSuccess(path: path, type: type, data: data) { sutResult in
                            result = sutResult
                            done()
                        }
                    }
                }

                it("THEN it should return a valid result") {
                    expect(result).toNot(beNil())
                    expect(result?.data).to(equalOrNil(expectedResult.data))
                    expect(result?.statusCode).to(equal(expectedResult.statusCode))
                    expect(result?.headerFields.keys).to(equal(expectedResult.headerFields.keys))

                    expect(task).to(be(expectedReturnTask))
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

/// A Nimble matcher that succeeds when the actual value is equal to the expected value.
/// Values can support equal by supporting the Equatable protocol.
///
/// @see beCloseTo if you want to match imprecise types (eg - floats, doubles).
public func equalOrNil<T: Equatable>(_ expectedValue: T?) -> Predicate<T> {
    return Predicate.define("equal <\(stringify(expectedValue))>") { actualExpression, msg in
        let actualValue = try actualExpression.evaluate()
        switch (expectedValue, actualValue) {
        case (nil, _?):
            return PredicateResult(bool: true, message: msg)
        case (nil, nil), (_, nil):
            return PredicateResult(status: .fail, message: msg)
        case (let expected?, let actual?):
            let matches = expected == actual
            return PredicateResult(bool: matches, message: msg)
        }
    }
}
