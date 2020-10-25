import XCTest
import Quick
import Nimble
@testable import Networker

final class NetworkerCancellableTests: QuickSpec {
    override func spec() {
        describe("GIVEN an URLSession with running task") {
            var task: URLSessionTaskMock!
            var sessionTasks: [URLSessionTaskMock]!

            var session: URLSessionMock!
            var sut: NetworkCancellable!
            beforeEach {
                session = .init()
                task = URLSessionTaskMock(taskIdentifier: 123456)
                sessionTasks = [task]
                session.getTasksCompletion = { completion in
                    completion(sessionTasks)
                }
                sut = Networker(session: session)
            }

            context("WHEN we call cancelTasks with an invalid task identifier") {
                let invalidID = 98766
                beforeEach {
                    assert(!sessionTasks.contains(where: { $0.taskIdentifier == invalidID }))
                    waitUntil { (done) in
                        sut.cancelTask(with: invalidID) {
                            done()
                        }
                    }
                }

                it("THEN it should call the session getTasks and not call any of its task methods") {
                    expect(session.didCallUpload).to(beFalse())
                    expect(session.didCallRequest).to(beFalse())
                    expect(session.didCallDownload).to(beFalse())

                    expect(session.getTasksCallCount).to(equal(1))
                    expect(task.didCallCancel).to(beFalse())
                    expect(task.didCallResume).to(beFalse())
                    expect(sessionTasks.allSatisfy { $0.didCallResume == false && $0.didCallCancel == false }).to(beTrue())
                }
            }

            context("WHEN we call cancelTasks with a valid task identifier") {
                beforeEach {
                    waitUntil { (done) in
                        sut.cancelTask(with: task.taskIdentifier) {
                            done()
                        }
                    }
                }

                it("THEN it should call the session getTasks and ask for the task to be cancelled") {
                    expect(session.didCallUpload).to(beFalse())
                    expect(session.didCallRequest).to(beFalse())
                    expect(session.didCallDownload).to(beFalse())

                    expect(session.getTasksCallCount).to(equal(1))

                    var otherSessionTasks = sessionTasks!
                    otherSessionTasks.removeAll { $0.taskIdentifier == task.taskIdentifier }

                    expect(otherSessionTasks.allSatisfy { $0.didCallResume == false && $0.didCallCancel == false }).to(beTrue())
                }
            }

            context("WHEN we call cancelTasks") {
                beforeEach {
                    waitUntil { (done) in
                        sut.cancelTasks {
                            done()
                        }
                    }
                }

                it("THEN it should call the session getTasks and ask for the task to be cancelled") {
                    expect(session.didCallUpload).to(beFalse())
                    expect(session.didCallRequest).to(beFalse())
                    expect(session.didCallDownload).to(beFalse())

                    expect(session.getTasksCallCount).to(equal(1))

                    expect(sessionTasks.allSatisfy { $0.didCallResume == false && $0.cancelCallCount == 1 }).to(beTrue())
                }
            }
        }
    }
}
