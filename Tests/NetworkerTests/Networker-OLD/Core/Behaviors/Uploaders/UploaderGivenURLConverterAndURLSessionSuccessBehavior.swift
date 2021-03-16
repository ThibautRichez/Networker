////
////  UploaderGivenURLConverterAndURLSessionSuccessBehavior.swift
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
//struct UploaderGivenURLConverterAndURLSessionSuccessContext {
//    var expectedResult: NetworkUploaderResult
//    var path: String
//    var method: HTTPMethod = .post
//    var data: Data?
//    var expectedRequestURL: String
//    var expectedTaskResult: URLSessionTaskMock
//    var session: URLSessionMock
//    var queues: NetworkerQueuesMock
//    var sut: Networker
//}
//
//final class UploaderGivenURLConverterAndURLSessionSuccessBehavior: Behavior<UploaderGivenURLConverterAndURLSessionSuccessContext> {
//    override class func spec(_ aContext: @escaping () -> UploaderGivenURLConverterAndURLSessionSuccessContext) {
//        describe("GIVEN a valid path and a context that produce an error") {
//            var currentContext: UploaderGivenURLConverterAndURLSessionSuccessContext!
//            var path: String!
//            var method: HTTPMethod!
//            var data: Data!
//            var session: URLSessionMock!
//            var queues: NetworkerQueuesMock!
//            var sut: Networker!
//            beforeEach {
//                currentContext = aContext()
//                path = currentContext.path
//                method = currentContext.method
//                data = currentContext.data
//                session = currentContext.session
//                queues = currentContext.queues
//                sut = currentContext.sut
//            }
//            
//            context("WHEN we execute the upload method") {
//                var task: URLSessionTaskMock?
//                var result: NetworkUploaderResult?
//                
//                beforeEach {
//                    waitUntil { (done) in
//                        task = sut.upload(
//                            data,
//                            to: path,
//                            method: method,
//                            completion: { (sutResult) in
//                                result = try? sutResult.get()
//                                done()
//                            }) as? URLSessionTaskMock
//                    }
//                }
//                
//                itBehavesLike(DefaultBehavior.self) {
//                    .init(context: currentContext, task: task, result: result)
//                }
//            }
//            
//            describe("WHEN we call the Encodable upload methods") {
//                
//                describe("WHEN using a type that always Encode successfully") {
//                    let model = SuccessEncodable()
//                    context("WHEN we use a path") {
//                        var task: URLSessionTaskMock?
//                        var result: NetworkUploaderResult?
//                        
//                        beforeEach {
//                            waitUntil { (done) in
//                                task = sut.upload(
//                                    model,
//                                    to: path,
//                                    method: method,
//                                    encoder: JSONEncoder()) { (sutResult) in
//                                    result = try? sutResult.get()
//                                    done()
//                                } as? URLSessionTaskMock
//                            }
//                        }
//                        
//                        itBehavesLike(DefaultBehavior.self) {
//                            .init(context: currentContext, task: task, result: result)
//                        }
//                    }
//                    context("WHEN we use an URL") {
//                        var task: URLSessionTaskMock?
//                        var result: NetworkUploaderResult?
//                        
//                        beforeEach {
//                            waitUntil { (done) in
//                                task = sut.upload(
//                                    model,
//                                    to: URL(string: path)!,
//                                    method: method,
//                                    encoder: JSONEncoder()) { (sutResult) in
//                                    result = try? sutResult.get()
//                                    done()
//                                } as? URLSessionTaskMock
//                            }
//                        }
//                        
//                        itBehavesLike(DefaultBehavior.self) {
//                            .init(context: currentContext, task: task, result: result)
//                        }
//                    }
//                    context("WHEN we use an URLRequest") {
//                        var task: URLSessionTaskMock?
//                        var result: NetworkUploaderResult?
//                        
//                        beforeEach {
//                            waitUntil { (done) in
//                                task = sut.upload(
//                                    model,
//                                    with: URLRequest(url: URL(string: path)!),
//                                    encoder: JSONEncoder()) { (sutResult) in
//                                    result = try? sutResult.get()
//                                    done()
//                                } as? URLSessionTaskMock
//                            }
//                        }
//                        
//                        itBehavesLike(DefaultBehavior.self) {
//                            .init(context: currentContext, task: task, result: result)
//                        }
//                    }
//                }
//                
//                describe("WHEN using a type that will fail to Encode") {
//                    let model = ErrorEncodable()
//                    context("WHEN we use a path") {
//                        var task: URLSessionTaskMock?
//                        var error: NetworkerError?
//                        
//                        beforeEach {
//                            waitUntil { (done) in
//                                task = sut.upload(
//                                    model,
//                                    to: path,
//                                    method: method,
//                                    encoder: JSONEncoder()) { (result) in
//                                    error = result.error
//                                    done()
//                                } as? URLSessionTaskMock
//                            }
//                        }
//                        
//                        itBehavesLike(EncodableFailureBehavior.self) {
//                            .init(
//                                session: session,
//                                queues: queues,
//                                task: task,
//                                error: error,
//                                expectedError: .encoder(ErrorEncodable.Error.generic)
//                            )
//                        }
//                    }
//                    context("WHEN we use an URL") {
//                        var task: URLSessionTaskMock?
//                        var error: NetworkerError?
//                        
//                        beforeEach {
//                            waitUntil { (done) in
//                                task = sut.upload(
//                                    model,
//                                    to: URL(string: path)!,
//                                    method: method,
//                                    encoder: JSONEncoder()) { (result) in
//                                    error = result.error
//                                    done()
//                                } as? URLSessionTaskMock
//                            }
//                        }
//                        
//                        itBehavesLike(EncodableFailureBehavior.self) {
//                            .init(
//                                session: session,
//                                queues: queues,
//                                task: task,
//                                error: error,
//                                expectedError: .encoder(ErrorEncodable.Error.generic)
//                            )
//                        }
//                    }
//                    context("WHEN we use an URLRequest") {
//                        var task: URLSessionTaskMock?
//                        var error: NetworkerError?
//                        
//                        beforeEach {
//                            waitUntil { (done) in
//                                task = sut.upload(
//                                    model,
//                                    with: URLRequest(url: URL(string: path)!),
//                                    encoder: JSONEncoder()) { (result) in
//                                    error = result.error
//                                    done()
//                                } as? URLSessionTaskMock
//                            }
//                        }
//                        
//                        itBehavesLike(EncodableFailureBehavior.self) {
//                            .init(
//                                session: session,
//                                queues: queues,
//                                task: task,
//                                error: error,
//                                expectedError: .encoder(ErrorEncodable.Error.generic)
//                            )
//                        }
//                    }
//                }
//            }
//        }
//    }
//}
//
//fileprivate struct DefaultContext {
//    var context: UploaderGivenURLConverterAndURLSessionSuccessContext
//    var task: URLSessionTaskMock?
//    var result: NetworkUploaderResult?
//}
//
//fileprivate final class DefaultBehavior: Behavior<DefaultContext> {
//    override class func spec(_ aContext: @escaping () -> DefaultContext) {
//        describe("GIVEN a valid path and a context that produce an error") {
//            var expectedResult: NetworkUploaderResult!
//            var path: String!
//            var method: HTTPMethod!
//            var expectedRequestURL: String!
//            var expectedReturnTask: URLSessionTaskMock!
//            var session: URLSessionMock!
//            var queues: NetworkerQueuesMock!
//            var sut: Networker!
//            var task: URLSessionTaskMock?
//            var result: NetworkUploaderResult?
//            beforeEach {
//                let defaultContext = aContext()
//                let context = defaultContext.context
//                
//                expectedResult = context.expectedResult
//                path = context.path
//                method = context.method
//                expectedRequestURL = context.expectedRequestURL
//                expectedReturnTask = context.expectedTaskResult
//                session = context.session
//                queues = context.queues
//                sut = context.sut
//                
//                task = defaultContext.task
//                result = defaultContext.result
//            }
//            
//            it("THEN it should return a valid result") {
//                expect(result).toNot(beNil())
//                if expectedResult.data == nil {
//                    expect(result?.data).to(beNil())
//                } else {
//                    expect(result?.data).to(equal(expectedResult.data))
//                }
//                
//                expect(result?.statusCode).to(equal(expectedResult.statusCode))
//                expect(result?.headerFields.keys).to(equal(expectedResult.headerFields.keys))
//                
//                expect(task).to(be(expectedReturnTask))
//                expect(task?.resumeCallCount).to(equal(1))
//                expect(task?.didCallCancel).to(beFalse())
//                
//                expect(session.uploadCallCount).to(equal(1))
//                expect(session.uploadArguments.count).to(equal(1))
//                let requestURL = try! sut.makeURL(from: path)
//                expect(requestURL).to(equal(URL(string: expectedRequestURL)))
//                expect(session.uploadArguments.first?.request.url?.absoluteString).to(
//                    equal(sut.makeURLRequest(requestURL, method: method).url?.absoluteString)
//                )
//                
//                expect(session.didCallRequest).to(beFalse())
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
