//
//  RequesterGivenURLConverterAndURLSessionSuccessBehavior.swift
//  
//
//  Created by RICHEZ Thibaut on 10/27/20.
//

import Foundation
import Quick
import Nimble
@testable import Networker

typealias DecodeEquatable = Decodable & Equatable

struct SuccessDecodable: DecodeEquatable {}
struct ErrorDecodable: DecodeEquatable {
    var title: String
    var subtitle: String
}

struct RequesterGivenURLConverterAndURLSessionSuccessContext {
    var expectedResult: NetworkRequesterResult
    var path: String
    var expectedRequestURL: String
    var expectedTaskResult: URLSessionTaskMock
    var session: URLSessionMock
    var queues: NetworkerQueuesMock
    var sut: Networker
}

final class RequesterGivenURLConverterAndURLSessionSuccessBehavior: Behavior<RequesterGivenURLConverterAndURLSessionSuccessContext> {
    override class func spec(_ aContext: @escaping () -> RequesterGivenURLConverterAndURLSessionSuccessContext) {
        describe("GIVEN a valid path and a context that produce an error") {
            var currentContext: RequesterGivenURLConverterAndURLSessionSuccessContext!
            var path: String!
            var sut: Networker!
            beforeEach {
                currentContext = aContext()
                path = currentContext.path
                sut = currentContext.sut
            }

            context("WHEN we call request") {
                var task: URLSessionTaskMock?
                var result: NetworkRequesterResult?

                beforeEach {
                    waitUntil { (done) in
                        task = sut.request(path: path, completion: { (sutResult) in
                            result = try? sutResult.get()
                            done()
                        }) as? URLSessionTaskMock
                    }
                }

                itBehavesLike(DefaultBehavior.self) {
                    .init(context: currentContext, task: task, result: result)
                }
            }

            describe("WHEN we call the Decodable requests methods") {

                describe("WHEN using a type that always Decode successfully") {
                    context("WHEN we use a path") {
                        var result: Result<SuccessDecodable, NetworkerError>!
                        var task: URLSessionTaskMock?

                        beforeEach {
                            waitUntil { (done) in
                                task = sut.request(
                                    decoder: JSONDecoder(),
                                    atPath: path,
                                    completion: { (taskResult: Result<SuccessDecodable, NetworkerError>) in
                                        result = taskResult
                                        done()
                                    }) as? URLSessionTaskMock
                            }
                        }

                        itBehavesLike(DecodableBehavior.self) {
                            .init(
                                context: currentContext,
                                task: task,
                                result: result,
                                expectedResult: .success(SuccessDecodable())
                            )
                        }
                    }
                    context("WHEN we use an URL") {
                        var result: Result<SuccessDecodable, NetworkerError>!
                        var task: URLSessionTaskMock?

                        beforeEach {
                            waitUntil { (done) in
                                task = sut.request(
                                    decoder: JSONDecoder(),
                                    url: URL(string: path)!,
                                    completion: { (taskResult: Result<SuccessDecodable, NetworkerError>) in
                                        result = taskResult
                                        done()
                                    }) as? URLSessionTaskMock
                            }
                        }

                        itBehavesLike(DecodableBehavior.self) {
                            .init(
                                context: currentContext,
                                task: task,
                                result: result,
                                expectedResult: .success(SuccessDecodable())
                            )
                        }
                    }
                    context("WHEN we use an URLRequest") {
                        var result: Result<SuccessDecodable, NetworkerError>!
                        var task: URLSessionTaskMock?

                        beforeEach {
                            waitUntil { (done) in
                                task = sut.request(
                                    decoder: JSONDecoder(),
                                    urlRequest: URLRequest(url: URL(string: path)!),
                                    completion: { (taskResult: Result<SuccessDecodable, NetworkerError>) in
                                        result = taskResult
                                        done()
                                    }) as? URLSessionTaskMock
                            }
                        }

                        itBehavesLike(DecodableBehavior.self) {
                            .init(
                                context: currentContext,
                                task: task,
                                result: result,
                                expectedResult: .success(SuccessDecodable())
                            )
                        }
                    }
                }

                describe("WHEN using a type that will fail to Decode") {
                    context("WHEN we use a path") {
                        var result: Result<ErrorDecodable, NetworkerError>!
                        var task: URLSessionTaskMock?

                        beforeEach {
                            waitUntil { (done) in
                                task = sut.request(
                                    decoder: JSONDecoder(),
                                    atPath: path,
                                    completion: { (taskResult: Result<ErrorDecodable, NetworkerError>) in
                                        result = taskResult
                                        done()
                                    }) as? URLSessionTaskMock
                            }
                        }

                        itBehavesLike(DecodableBehavior.self) {
                            .init(
                                context: currentContext,
                                task: task,
                                result: result,
                                expectedResult: .failure(
                                    .decoder(result.error?.decoderNestedError ?? NSError(domain: "", code: 0, userInfo: nil))
                                )
                            )
                        }
                    }
                    context("WHEN we use an URL") {
                        var result: Result<ErrorDecodable, NetworkerError>!
                        var task: URLSessionTaskMock?

                        beforeEach {
                            waitUntil { (done) in
                                task = sut.request(
                                    decoder: JSONDecoder(),
                                    url: URL(string: path)!,
                                    completion: { (taskResult: Result<ErrorDecodable, NetworkerError>) in
                                        result = taskResult
                                        done()
                                    }) as? URLSessionTaskMock
                            }
                        }

                        itBehavesLike(DecodableBehavior.self) {
                            .init(
                                context: currentContext,
                                task: task,
                                result: result,
                                expectedResult: .failure(
                                    .decoder(result.error?.decoderNestedError ?? NSError(domain: "", code: 0, userInfo: nil))
                                )
                            )
                        }
                    }
                    context("WHEN we use an URLRequest") {
                        var result: Result<ErrorDecodable, NetworkerError>!
                        var task: URLSessionTaskMock?

                        beforeEach {
                            waitUntil { (done) in
                                task = sut.request(
                                    decoder: JSONDecoder(),
                                    urlRequest: URLRequest(url: URL(string: path)!),
                                    completion: { (taskResult: Result<ErrorDecodable, NetworkerError>) in
                                        result = taskResult
                                        done()
                                    }) as? URLSessionTaskMock
                            }
                        }

                        itBehavesLike(DecodableBehavior.self) {
                            .init(
                                context: currentContext,
                                task: task,
                                result: result,
                                expectedResult: .failure(
                                    .decoder(result.error?.decoderNestedError ?? NSError(domain: "", code: 0, userInfo: nil))
                                )
                            )
                        }
                    }
                }
            }
        }
    }
}

fileprivate struct DefaultBehaviorContext {
    var context: RequesterGivenURLConverterAndURLSessionSuccessContext
    var task: URLSessionTaskMock?
    var result: NetworkRequesterResult?
}

fileprivate final class DefaultBehavior: Behavior<DefaultBehaviorContext> {
    override class func spec(_ aContext: @escaping () -> DefaultBehaviorContext) {
        describe("GIVEN a valid path and a context that produce an error") {
            var expectedResult: NetworkRequesterResult!
            var path: String!
            var expectedRequestURL: String!
            var expectedErrorExecutorReturn: URLSessionTaskMock!
            var session: URLSessionMock!
            var queues: NetworkerQueuesMock!
            var sut: Networker!
            var task: URLSessionTaskMock?
            var result: NetworkRequesterResult?
            beforeEach {
                let defaultContext = aContext()
                let context = defaultContext.context

                expectedResult = context.expectedResult
                path = context.path
                expectedRequestURL = context.expectedRequestURL
                expectedErrorExecutorReturn = context.expectedTaskResult
                session = context.session
                queues = context.queues
                sut = context.sut
                task = defaultContext.task
                result = defaultContext.result
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

fileprivate struct DecodableBehaviorContext<T: DecodeEquatable> {
    var context: RequesterGivenURLConverterAndURLSessionSuccessContext
    var task: URLSessionTaskMock?
    var result: Result<T, NetworkerError>
    var expectedResult: Result<T, NetworkerError>
}

fileprivate final class DecodableBehavior<T: DecodeEquatable>: Behavior<DecodableBehaviorContext<T>> {
    override class func spec(_ aContext: @escaping () -> DecodableBehaviorContext<T>) {
        describe("GIVEN a valid path and a context that produce an error") {
            var path: String!
            var expectedRequestURL: String!
            var expectedErrorExecutorReturn: URLSessionTaskMock!
            var session: URLSessionMock!
            var queues: NetworkerQueuesMock!
            var sut: Networker!
            var task: URLSessionTaskMock?
            var result: Result<T, NetworkerError>!
            var expectedResult: Result<T, NetworkerError>!
            beforeEach {
                let defaultContext = aContext()
                let context = defaultContext.context

                path = context.path
                expectedRequestURL = context.expectedRequestURL
                expectedErrorExecutorReturn = context.expectedTaskResult
                session = context.session
                queues = context.queues
                sut = context.sut
                task = defaultContext.task
                result = defaultContext.result
                expectedResult = defaultContext.expectedResult
            }

            it("THEN it should return a valid result") {
                expect(result).toNot(beNil())
                expect(result).to(equal(expectedResult))

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

extension NetworkerError {
    var decoderNestedError: Error? {
        guard case .decoder(let nested) = self else {
            return nil
        }

        return nested
    }
}
