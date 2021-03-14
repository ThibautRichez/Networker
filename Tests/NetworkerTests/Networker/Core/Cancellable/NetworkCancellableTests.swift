//import XCTest
//import Quick
//import Nimble
//@testable import Networker
//
//final class NetworkerCancellableTests: QuickSpec {
//    override func spec() {
//        describe("GIVEN an URLSession mock and a NetworkerQueues mock") {
//            var session: URLSessionMock!
//            var queues: NetworkerQueuesMock!
//            var sut: Networker!
//            beforeEach {
//                session = .init()
//                queues = .init()
//                sut = .init(session: session, queues: queues)
//            }
//
//            describe("GIVEN an URLSession with running task") {
//                var task: URLSessionTaskMock!
//                var sessionTasks: [URLSessionTaskMock]!
//                beforeEach {
//                    task = URLSessionTaskMock(taskIdentifier: 123456)
//                    sessionTasks = [task]
//                    session.getTasksCompletion = { completion in
//                        completion(sessionTasks)
//                    }
//                }
//
//                context("WHEN we call cancelTasks with an invalid task identifier") {
//                    let invalidID = 98766
//                    beforeEach {
//                        assert(!sessionTasks.contains(where: { $0.taskIdentifier == invalidID }))
//                        waitUntil { (done) in
//                            sut.cancelTask(with: invalidID) {
//                                done()
//                            }
//                        }
//                    }
//
//                    it("THEN it should call the session getTasks and not call any of its task methods") {
//                        expect(session.getTasksCallCount).to(equal(1))
//                        expect(sessionTasks.allSatisfy { $0.didCallResume == false && $0.didCallCancel == false }).to(beTrue())
//
//                        expect(session.didCallUpload).to(beFalse())
//                        expect(session.didCallRequest).to(beFalse())
//                        expect(session.didCallDownload).to(beFalse())
//
//                        expect(queues.didCallAsyncCallback).to(beFalse())
//                        expect(queues.didCallAddOperation).to(beFalse())
//                        expect(queues.didCallCancelAllOperations).to(beFalse())
//                    }
//                }
//
//                context("WHEN we call cancelTasks with a valid task identifier") {
//                    beforeEach {
//                        waitUntil { (done) in
//                            sut.cancelTask(with: task.taskIdentifier) {
//                                done()
//                            }
//                        }
//                    }
//
//                    it("THEN it should call the session getTasks and ask for the task to be cancelled") {
//                        expect(session.getTasksCallCount).to(equal(1))
//                        expect(task.didCallCancel).to(beTrue())
//                        expect(task.didCallResume).to(beFalse())
//
//                        var otherSessionTasks = sessionTasks!
//                        otherSessionTasks.removeAll { $0.taskIdentifier == task.taskIdentifier }
//                        expect(otherSessionTasks.allSatisfy { $0.didCallResume == false && $0.didCallCancel == false }).to(beTrue())
//
//                        expect(session.didCallUpload).to(beFalse())
//                        expect(session.didCallRequest).to(beFalse())
//                        expect(session.didCallDownload).to(beFalse())
//
//                        expect(queues.didCallAsyncCallback).to(beFalse())
//                        expect(queues.didCallAddOperation).to(beFalse())
//                        expect(queues.didCallCancelAllOperations).to(beFalse())
//                    }
//                }
//
//                context("WHEN we call cancelTasks") {
//                    beforeEach {
//                        waitUntil { (done) in
//                            sut.cancelTasks {
//                                done()
//                            }
//                        }
//                    }
//
//                    it("THEN it should call the session getTasks and ask for the task to be cancelled") {
//                        expect(session.getTasksCallCount).to(equal(1))
//                        expect(sessionTasks.allSatisfy { $0.didCallResume == false && $0.cancelCallCount == 1 }).to(beTrue())
//
//                        expect(session.didCallUpload).to(beFalse())
//                        expect(session.didCallRequest).to(beFalse())
//                        expect(session.didCallDownload).to(beFalse())
//
//                        expect(queues.didCallAsyncCallback).to(beFalse())
//                        expect(queues.didCallAddOperation).to(beFalse())
//                        expect(queues.didCallCancelAllOperations).to(beFalse())
//                    }
//                }
//            }
//
//            context("WHEN we call cancelAllOperations") {
//                beforeEach {
//                    sut.cancelAllOperations()
//                }
//
//                it("THEN it should call the queues cancelAllOperations method") {
//                    expect(queues.cancelAllOperationsCallCount).to(equal(1))
//
//                    expect(session.didCallUpload).to(beFalse())
//                    expect(session.didCallRequest).to(beFalse())
//                    expect(session.didCallDownload).to(beFalse())
//                    expect(session.didCallGetTasks).to(beFalse())
//
//                    expect(queues.didCallAsyncCallback).to(beFalse())
//                    expect(queues.didCallAddOperation).to(beFalse())
//                }
//            }
//
//            context("WHEN we call cancelAllOperations") {
//
//            }
//        }
//    }
//}
