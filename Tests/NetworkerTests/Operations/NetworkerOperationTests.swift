//
//  NetworkerOperationTests.swift
//  
//
//  Created by RICHEZ Thibaut on 1/24/21.
//

import Foundation
import XCTest
import Quick
import Nimble
@testable import Networker

final class NetworkerOperationTests: QuickSpec {
    override func spec() {
        describe("GIVEN mock session request") {
            var sessionReturnTask: URLSessionTaskMock!
            var sut: NetworkerOperation!
            beforeEach {
                sessionReturnTask = .init()
                let session = URLSessionMock()
                session.requestResult = { sessionReturnTask }
                session.requestResultCompletion = { completion in
                    completion(nil, nil, nil)
                }

                let request = URLRequest(url: URL(string: "https://test.com")!)
                sut = .init(
                    request: request,
                    executor: session.request(with:completion:), completion: { (_, _, _) in
                    })
            }

            itBehavesLike(DefaultBehavior.self) {
                .init(sessionReturnTask: sessionReturnTask, sut: sut)
            }
        }

        describe("GIVEN mock session upload") {
            var sessionReturnTask: URLSessionTaskMock!
            var sut: NetworkerOperation!
            beforeEach {
                sessionReturnTask = .init()
                let session = URLSessionMock()
                session.uploadResult = { sessionReturnTask }
                session.uploadResultCompletion = { completion in
                    completion(nil, nil, nil)
                }

                let request = URLRequest(url: URL(string: "https://test.com")!)
                sut = .init(
                    request: request,
                    data: Data(),
                    executor: session.upload(with:from:completion:),
                    completion: { (_, _, _) in

                    })
            }

            itBehavesLike(DefaultBehavior.self) {
                .init(sessionReturnTask: sessionReturnTask, sut: sut)
            }
        }
    }
}

fileprivate struct DefaultContext {
    var sessionReturnTask: URLSessionTaskMock
    var sut: NetworkerOperation
}

fileprivate final class DefaultBehavior: Behavior<DefaultContext> {
    override class func spec(_ aContext: @escaping () -> DefaultContext) {
        var sessionReturnTask: URLSessionTaskMock!
        var sut: NetworkerOperation!
        beforeEach {
            let context = aContext()
            sessionReturnTask = context.sessionReturnTask
            sut = context.sut
        }

        it("THEN the operation task should be set to the session return task") {
            expect(sut.task).to(be(sessionReturnTask))
        }

        context("WHEN we call start") {
            context("WHEN the operation is cancelled") {
                beforeEach {
                    sut.cancel()
                    sut.start()
                }

                it("THEN isExecuting should be false and isFinished true") {
                    expect(sessionReturnTask.cancelCallCount).to(equal(1))
                    expect(sessionReturnTask.didCallResume).to(beFalse())

                    expect(sut.isExecuting).to(beFalse())
                    expect(sut.isFinished).to(beTrue())
                    expect(sut.isAsynchronous).to(beTrue())
                }
            }

            context("WHEN the operation is not ready") {
                beforeEach {
                    let dependency = AsyncOperation()
                    sut.addDependency(dependency)
                    sut.start()
                }

                it("THEN isExecuting and isFinished should have their default value") {
                    expect(sessionReturnTask.didCallResume).to(beFalse())
                    expect(sessionReturnTask.didCallCancel).to(beFalse())

                    expect(sut.isExecuting).to(beFalse())
                    expect(sut.isFinished).to(beFalse())
                    expect(sut.isAsynchronous).to(beTrue())
                }
            }

            context("WHEN the operation is already finished") {
                beforeEach {
                    sut.finish()
                    sut.start()
                }

                it("THEN isExecuting should be false and isFinished true") {
                    expect(sessionReturnTask.didCallResume).to(beFalse())
                    expect(sessionReturnTask.didCallCancel).to(beFalse())

                    expect(sut.isExecuting).to(beFalse())
                    expect(sut.isFinished).to(beTrue())
                    expect(sut.isAsynchronous).to(beTrue())
                }
            }

            context("WHEN the operation is ready") {
                beforeEach {
                    sut.start()
                }

                it("THEN it should resume the task and finish the operation") {
                    expect(sessionReturnTask.resumeCallCount).to(equal(1))
                    expect(sessionReturnTask.didCallCancel).to(beFalse())

                    expect(sut.isFinished).to(beTrue())
                    expect(sut.isExecuting).to(beFalse())
                    expect(sut.isAsynchronous).to(beTrue())
                }
            }
        }

        context("WHEN we call main") {
            beforeEach {
                sut.main()
            }

            it("THEN it should resume the task and call finish") {
                expect(sessionReturnTask.resumeCallCount).to(equal(1))
                expect(sessionReturnTask.didCallCancel).to(beFalse())

                expect(sut.isExecuting).to(beFalse())
                expect(sut.isFinished).to(beTrue())
                expect(sut.isAsynchronous).to(beTrue())
            }
        }

        context("WHEN we call finish") {
            beforeEach {
                sut.finish()
            }

            it("THEN isExecuting should be false and isFinished true") {
                expect(sessionReturnTask.didCallResume).to(beFalse())
                expect(sessionReturnTask.didCallCancel).to(beFalse())

                expect(sut.isExecuting).to(beFalse())
                expect(sut.isFinished).to(beTrue())
                expect(sut.isAsynchronous).to(beTrue())
            }
        }

        context("WHEN we call cancel") {
            beforeEach {
                sut.cancel()
            }

            it("THEN it should cancel the task") {
                expect(sessionReturnTask.cancelCallCount).to(equal(1))
                expect(sessionReturnTask.didCallResume).to(beFalse())

                expect(sut.isExecuting).to(beFalse())
                expect(sut.isFinished).to(beTrue())
                expect(sut.isAsynchronous).to(beTrue())
            }
        }
    }
}

// TODO: add THEN test
final class ThenTests: XCTestCase {
    func test_Then() {
        let sut = Networker()
        sut.request("https://google.com") { result in
            print("TESTS: DONE")
        }?
        .retry(.count(3))
        .then {
            print("TESTS: Start 1st comp")
            sut.request( "https://google.com") { result in
                print("TESTS: 1st THEN: DONE")
            }
        }
        .then {
            print("TESTS: Start 2nd comp")
            sut.request( "https://google.com") { result in
                print("TESTS: 2nd THEN: DONE")
            }
        }
    }
}
