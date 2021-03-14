////
////  RequesterGivenURLConverterSuccessAndURLSessionErrorBehavior.swift
////  
////
////  Created by RICHEZ Thibaut on 10/27/20.
////
//
//import Foundation
//import Quick
//import Nimble
//@testable import Networker
//
//struct RequesterGivenURLConverterSuccessAndURLSessionErrorContext {
//    var expectedError: NetworkerError
//    var path: String
//    var expectedRequestURL: String
//    var expectedTaskResult: URLSessionTaskMock
//    var session: URLSessionMock
//    var queues: NetworkerQueuesMock
//    var sut: Networker
//}
//
//final class RequesterGivenURLConverterSuccessAndURLSessionErrorBehavior: Behavior<RequesterGivenURLConverterSuccessAndURLSessionErrorContext> {
//    override class func spec(_ aContext: @escaping () -> RequesterGivenURLConverterSuccessAndURLSessionErrorContext) {
//        describe("GIVEN a valid path and a context that produce an error") {
//            var currentContext: RequesterGivenURLConverterSuccessAndURLSessionErrorContext!
//            var path: String!
//            var sut: Networker!
//            beforeEach {
//                currentContext = aContext()
//                path = currentContext.path
//                sut = currentContext.sut
//            }
//
//            context("WHEN we call request") {
//                var task: URLSessionTaskMock?
//                var error: NetworkerError?
//
//                beforeEach {
//                    waitUntil { (done) in
//                        task = sut.request(path) { (result) in
//                            error = result.error
//                            done()
//                        } as? URLSessionTaskMock
//                    }
//                }
//
//                itBehavesLike(DefaultBehavior.self) {
//                    .init(context: currentContext, task: task, error: error)
//                }
//            }
//
//            describe("WHEN we call the Decodable requests methods") {
//                struct AnyDecodable: Decodable {}
//                context("WHEN we use a path") {
//                    var task: URLSessionTaskMock?
//                    var error: NetworkerError?
//
//                    beforeEach {
//                        waitUntil { (done) in
//                            task = sut.request(
//                                path,
//                                decoder: JSONDecoder(),
//                                completion: { (result: Result<AnyDecodable, NetworkerError>) in
//                                    error = result.error
//                                    done()
//                                }) as? URLSessionTaskMock
//                        }
//                    }
//
//                    itBehavesLike(DefaultBehavior.self) {
//                        .init(context: currentContext, task: task, error: error)
//                    }
//                }
//
//                context("WHEN we use an URL") {
//                    var task: URLSessionTaskMock?
//                    var error: NetworkerError?
//
//                    beforeEach {
//                        waitUntil { (done) in
//                            task = sut.request(
//                                URL(string: path)!,
//                                decoder: JSONDecoder(),
//                                completion: { (result: Result<AnyDecodable, NetworkerError>) in
//                                    error = result.error
//                                    done()
//                                }) as? URLSessionTaskMock
//                        }
//                    }
//
//                    itBehavesLike(DefaultBehavior.self) {
//                        .init(context: currentContext, task: task, error: error)
//                    }
//                }
//
//                context("WHEN we use an URLRequest") {
//                    var task: URLSessionTaskMock?
//                    var error: NetworkerError?
//
//                    beforeEach {
//                        waitUntil { (done) in
//                            task = sut.request(
//                                URLRequest(url: URL(string: path)!),
//                                decoder: JSONDecoder(),
//                                completion: { (result: Result<AnyDecodable, NetworkerError>) in
//                                    error = result.error
//                                    done()
//                                }) as? URLSessionTaskMock
//                        }
//                    }
//
//                    itBehavesLike(DefaultBehavior.self) {
//                        .init(context: currentContext, task: task, error: error)
//                    }
//                }
//            }
//        }
//    }
//}
//
//fileprivate struct DefaultBehaviorContext {
//    var context: RequesterGivenURLConverterSuccessAndURLSessionErrorContext
//    var task: URLSessionTaskMock?
//    var error: NetworkerError?
//}
//
//fileprivate final class DefaultBehavior: Behavior<DefaultBehaviorContext> {
//    override class func spec(_ aContext: @escaping () -> DefaultBehaviorContext) {
//        describe("GIVEN a valid path and a context that produce an error") {
//            var expectedError: NetworkerError!
//            var path: String!
//            var expectedRequestURL: String!
//            var expectedErrorExecutorReturn: URLSessionTaskMock!
//            var session: URLSessionMock!
//            var queues: NetworkerQueuesMock!
//            var sut: Networker!
//            var task: URLSessionTaskMock?
//            var error: NetworkerError?
//            beforeEach {
//                let defaultContext = aContext()
//                let context = defaultContext.context
//
//                expectedError = context.expectedError
//                path = context.path
//                expectedRequestURL = context.expectedRequestURL
//                expectedErrorExecutorReturn = context.expectedTaskResult
//                session = context.session
//                queues = context.queues
//                sut = context.sut
//                task = defaultContext.task
//                error = defaultContext.error
//            }
//
//            it("THEN the session request should be called and we should have the expected error") {
//                expect(error).to(matchError(expectedError))
//
//                expect(task).to(be(expectedErrorExecutorReturn))
//                expect(task?.resumeCallCount).to(equal(1))
//                expect(task?.didCallCancel).to(beFalse())
//
//                expect(session.requestCallCount).to(equal(1))
//                expect(session.requestArguments.count).to(equal(1))
//                let requestURL = try! sut.makeURL(from: path)
//                expect(requestURL).to(equal(URL(string: expectedRequestURL)))
//                expect(session.requestArguments.first).to(
//                    equal(sut.makeURLRequest(requestURL, method: .get))
//                )
//
//                expect(session.didCallUpload).to(beFalse())
//                expect(session.didCallDownload).to(beFalse())
//                expect(session.didCallGetTasks).to(beFalse())
//
//                expect(queues.asyncCallbackCallCount).to(equal(1))
//                expect(queues.addOperationCallCount).to(equal(1))
//                expect(queues.didCallCancelAllOperations).to(beFalse())
//            }
//        }
//    }
//}
