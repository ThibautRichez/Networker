//
//  UploaderGivenURLConverterSuccessAndURLSessionErrorBehavior.swift
//  
//
//  Created by RICHEZ Thibaut on 10/27/20.
//

import Foundation
import Quick
import Nimble
@testable import Networker

struct SuccessEncodable: Encodable {}
struct ErrorEncodable: Encodable {
    var title: String = ""

    func encode(to encoder: Encoder) throws {
        throw Error.generic
    }

    enum Error: Swift.Error {
        case generic
    }
}

struct UploaderGivenURLConverterSuccessAndURLSessionErrorContext {
    var expectedError: NetworkerError
    var path: String
    var type: NetworkUploaderType = .post
    var data: Data?
    var expectedRequestURL: String
    var expectedTaskResult: URLSessionTaskMock
    var session: URLSessionMock
    var queues: NetworkerQueuesMock
    var sut: Networker
}

final class UploaderGivenURLConverterSuccessAndURLSessionErrorBehavior: Behavior<UploaderGivenURLConverterSuccessAndURLSessionErrorContext> {
    override class func spec(_ aContext: @escaping () -> UploaderGivenURLConverterSuccessAndURLSessionErrorContext) {
        describe("GIVEN a valid path and a context that produce an error") {
            var currentContext: UploaderGivenURLConverterSuccessAndURLSessionErrorContext!
            var path: String!
            var type: NetworkUploaderType!
            var data: Data!
            var session: URLSessionMock!
            var queues: NetworkerQueuesMock!
            var sut: Networker!
            beforeEach {
                currentContext = aContext()
                path = currentContext.path
                type = currentContext.type
                data = currentContext.data
                session = currentContext.session
                queues = currentContext.queues
                sut = currentContext.sut
            }

            context("WHEN we execute the upload method") {
                var task: URLSessionTaskMock?
                var error: NetworkerError?

                beforeEach {
                    waitUntil { (done) in
                        task = sut.upload(
                            path: path,
                            type: type,
                            data: data,
                            completion: { (result) in
                                error = result.error
                                done()
                            }) as? URLSessionTaskMock
                    }
                }

                itBehavesLike(DefaultBehavior.self) {
                    .init(context: currentContext, task: task, error: error)
                }
            }

            describe("WHEN we call the Encodable upload methods") {

                describe("WHEN using a type that always Encode successfully") {
                    let model = SuccessEncodable()
                    context("WHEN we use a path") {
                        var task: URLSessionTaskMock?
                        var error: NetworkerError?

                        beforeEach {
                            waitUntil { (done) in
                                task = sut.upload(
                                    path: path,
                                    type: type,
                                    model: model,
                                    encoder: JSONEncoder()) { (result) in
                                    error = result.error
                                    done()
                                } as? URLSessionTaskMock
                            }
                        }

                        itBehavesLike(DefaultBehavior.self) {
                            .init(context: currentContext, task: task, error: error)
                        }
                    }
                    context("WHEN we use an URL") {
                        var task: URLSessionTaskMock?
                        var error: NetworkerError?

                        beforeEach {
                            waitUntil { (done) in
                                task = sut.upload(
                                    url: URL(string: path)!,
                                    type: type,
                                    model: model,
                                    encoder: JSONEncoder()) { (result) in
                                    error = result.error
                                    done()
                                } as? URLSessionTaskMock
                            }
                        }

                        itBehavesLike(DefaultBehavior.self) {
                            .init(context: currentContext, task: task, error: error)
                        }
                    }
                    context("WHEN we use an URLRequest") {
                        var task: URLSessionTaskMock?
                        var error: NetworkerError?

                        beforeEach {
                            waitUntil { (done) in
                                task = sut.upload(
                                    urlRequest: URLRequest(url: URL(string: path)!),
                                    model: model,
                                    encoder: JSONEncoder()) { (result) in
                                    error = result.error
                                    done()
                                } as? URLSessionTaskMock
                            }
                        }

                        itBehavesLike(DefaultBehavior.self) {
                            .init(context: currentContext, task: task, error: error)
                        }
                    }
                }

                describe("WHEN using a type that will fail to Encode") {
                    let model = ErrorEncodable()
                    context("WHEN we use a path") {
                        var task: URLSessionTaskMock?
                        var error: NetworkerError?

                        beforeEach {
                            waitUntil { (done) in
                                task = sut.upload(
                                    path: path,
                                    type: type,
                                    model: model,
                                    encoder: JSONEncoder()) { (result) in
                                    error = result.error
                                    done()
                                } as? URLSessionTaskMock
                            }
                        }

                        itBehavesLike(EncodableFailureBehavior.self) {
                            .init(
                                session: session,
                                queues: queues,
                                task: task,
                                error: error,
                                expectedError: .encoder(ErrorEncodable.Error.generic)
                            )
                        }
                    }
                    context("WHEN we use an URL") {
                        var task: URLSessionTaskMock?
                        var error: NetworkerError?

                        beforeEach {
                            waitUntil { (done) in
                                task = sut.upload(
                                    url: URL(string: path)!,
                                    type: type,
                                    model: model,
                                    encoder: JSONEncoder()) { (result) in
                                    error = result.error
                                    done()
                                } as? URLSessionTaskMock
                            }
                        }

                        itBehavesLike(EncodableFailureBehavior.self) {
                            .init(
                                session: session,
                                queues: queues,
                                task: task,
                                error: error,
                                expectedError: .encoder(ErrorEncodable.Error.generic)
                            )
                        }
                    }
                    context("WHEN we use an URLRequest") {
                        var task: URLSessionTaskMock?
                        var error: NetworkerError?

                        beforeEach {
                            waitUntil { (done) in
                                task = sut.upload(
                                    urlRequest: URLRequest(url: URL(string: path)!),
                                    model: model,
                                    encoder: JSONEncoder()) { (result) in
                                    error = result.error
                                    done()
                                } as? URLSessionTaskMock
                            }
                        }

                        itBehavesLike(EncodableFailureBehavior.self) {
                            .init(
                                session: session,
                                queues: queues,
                                task: task,
                                error: error,
                                expectedError: .encoder(ErrorEncodable.Error.generic)
                            )
                        }
                    }
                }
            }
        }
    }
}

fileprivate struct DefaultBehaviorContext {
    var context: UploaderGivenURLConverterSuccessAndURLSessionErrorContext
    var task: URLSessionTaskMock?
    var error: NetworkerError?
}

fileprivate class DefaultBehavior: Behavior<DefaultBehaviorContext> {
    override class func spec(_ aContext: @escaping () -> DefaultBehaviorContext) {
        var expectedError: NetworkerError!
        var path: String!
        var type: NetworkUploaderType!
        var expectedRequestURL: String!
        var expectedErrorExecutorReturn: URLSessionTaskMock!
        var session: URLSessionMock!
        var queues: NetworkerQueuesMock!
        var sut: Networker!
        var task: URLSessionTaskMock?
        var error: NetworkerError?
        beforeEach {
            let defaultContext = aContext()
            let context = defaultContext.context

            expectedError = context.expectedError
            path = context.path
            type = context.type
            expectedRequestURL = context.expectedRequestURL
            expectedErrorExecutorReturn = context.expectedTaskResult
            session = context.session
            queues = context.queues
            sut = context.sut

            task = defaultContext.task
            error = defaultContext.error
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
            expect(session.uploadArguments.first?.request.url?.absoluteString).to(
                equal(sut.makeURLRequest(for: type.requestType, with: requestURL).url?.absoluteString)
            )

            expect(session.didCallRequest).to(beFalse())
            expect(session.didCallDownload).to(beFalse())
            expect(session.didCallGetTasks).to(beFalse())

            expect(queues.asyncCallbackCallCount).to(equal(1))
            expect(queues.addOperationCallCount).to(equal(1))
            expect(queues.didCallCancelAllOperations).to(beFalse())
        }
    }
}

struct EncodableFailureContext {
    var session: URLSessionMock
    var queues: NetworkerQueuesMock
    var task: URLSessionTaskMock?
    var error: NetworkerError?
    var expectedError: NetworkerError
}

final class EncodableFailureBehavior: Behavior<EncodableFailureContext> {
    override class func spec(_ aContext: @escaping () -> EncodableFailureContext) {
        var session: URLSessionMock!
        var queues: NetworkerQueuesMock!
        var task: URLSessionTaskMock?
        var error: NetworkerError?
        var expectedError: NetworkerError!

        beforeEach {
            let context = aContext()

            session = context.session
            queues = context.queues
            task = context.task
            error = context.error
            expectedError = context.expectedError
        }

        it("THEN the session request should be called and we should have the expected error") {
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
