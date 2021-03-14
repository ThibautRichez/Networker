////
////  NetworkerGivenURLConverterSuccessBehavior.swift
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
//struct NetworkerGivenURLConverterSuccessContext {
//    var path: String
//    var expectedRequestURL: String
//    var session: URLSessionMock
//    var queues: NetworkerQueuesMock
//    var sut: Networker
//}
//
//final class NetworkerGivenURLConverterSuccessBehavior: Behavior<NetworkerGivenURLConverterSuccessContext> {
//    override class func spec(_ aContext: @escaping () -> NetworkerGivenURLConverterSuccessContext) {
//        describe("GIVEN a valid url with any URLSession and Networker ") {
//            var path: String!
//            var expectedRequestURL: String!
//            var session: URLSessionMock!
//            var queues: NetworkerQueuesMock!
//            var sessionReturnTask: URLSessionTaskMock!
//            var sut: Networker!
//            beforeEach {
//                path = aContext().path
//                expectedRequestURL = aContext().expectedRequestURL
//                session = aContext().session
//                queues = aContext().queues
//                sessionReturnTask = .init()
//                session.requestResult = { sessionReturnTask }
//                session.uploadResult = { sessionReturnTask }
//                session.downloadResult = { sessionReturnTask }
//                sut = aContext().sut
//            }
//
//            describe("GIVEN a session with an empty response") {
//                var expectedError: NetworkerError!
//                beforeEach {
//                    expectedError = .response(.empty)
//                    session.requestResultCompletion = { completion in
//                        completion(nil, nil, nil)
//                    }
//
//                    session.uploadResultCompletion = { completion in
//                        completion(nil, nil, nil)
//                    }
//
//                    session.downloadResultCompletion = { completion in
//                        completion(nil, nil, nil)
//                    }
//                }
//
//                itBehavesLike(RequesterGivenURLConverterSuccessAndURLSessionErrorBehavior.self) {
//                    .init(
//                        expectedError: expectedError,
//                        path: path,
//                        expectedRequestURL: expectedRequestURL,
//                        expectedTaskResult: sessionReturnTask,
//                        session: session,
//                        queues: queues,
//                        sut: sut
//                    )
//                }
//
//                itBehavesLike(UploaderGivenURLConverterSuccessAndURLSessionErrorBehavior.self) {
//                    .init(
//                        expectedError: expectedError,
//                        path: path,
//                        data: Data(),
//                        expectedRequestURL: expectedRequestURL,
//                        expectedTaskResult: sessionReturnTask,
//                        session: session,
//                        queues: queues,
//                        sut: sut
//                    )
//                }
//
//                itBehavesLike(DownloaderGivenURLConverterSuccessAndURLSessionErrorBehavior.self) {
//                    .init(
//                        expectedError: expectedError,
//                        path: path,
//                        expectedRequestURL: expectedRequestURL,
//                        expectedTaskResult: sessionReturnTask,
//                        session: session,
//                        queues: queues,
//                        sut: sut
//                    )
//                }
//            }
//
//            describe("GIVEN a session that returns an error") {
//                var requestError: Error!
//                var expectedError: NetworkerError!
//                beforeEach {
//                    requestError = NSError(domain: "error.test", code: 10, userInfo: nil)
//                    expectedError = .remote(.other(requestError))
//
//                    session.requestResultCompletion = { completion in
//                        completion(nil, nil, requestError)
//                    }
//
//                    session.uploadResultCompletion = { completion in
//                        completion(nil, nil, requestError)
//                    }
//
//                    session.downloadResultCompletion = { completion in
//                        completion(nil, nil, requestError)
//                    }
//                }
//
//                itBehavesLike(RequesterGivenURLConverterSuccessAndURLSessionErrorBehavior.self) {
//                    .init(
//                        expectedError: expectedError,
//                        path: path,
//                        expectedRequestURL: expectedRequestURL,
//                        expectedTaskResult: sessionReturnTask,
//                        session: session,
//                        queues: queues,
//                        sut: sut
//                    )
//                }
//
//                itBehavesLike(UploaderGivenURLConverterSuccessAndURLSessionErrorBehavior.self) {
//                    .init(
//                        expectedError: expectedError,
//                        path: path,
//                        data: Data(),
//                        expectedRequestURL: expectedRequestURL,
//                        expectedTaskResult: sessionReturnTask,
//                        session: session,
//                        queues: queues,
//                        sut: sut
//                    )
//                }
//
//                itBehavesLike(DownloaderGivenURLConverterSuccessAndURLSessionErrorBehavior.self) {
//                    .init(
//                        expectedError: expectedError,
//                        path: path,
//                        expectedRequestURL: expectedRequestURL,
//                        expectedTaskResult: sessionReturnTask,
//                        session: session,
//                        queues: queues,
//                        sut: sut
//                    )
//                }
//            }
//
//            describe("GIVEN a session that returns a reponse") {
//
//                describe("GIVEN an invalid response (should be HTTPURLResponse)") {
//                    var invalidReponse: URLResponse!
//                    var expectedError: NetworkerError!
//                    beforeEach {
//                        invalidReponse = .init()
//                        expectedError = .response(.invalid(invalidReponse))
//
//                        session.requestResultCompletion = { completion in
//                            completion(nil, invalidReponse, nil)
//                        }
//
//                        session.uploadResultCompletion = { completion in
//                            completion(nil, invalidReponse, nil)
//                        }
//
//                        session.downloadResultCompletion = { completion in
//                            completion(nil, invalidReponse, nil)
//                        }
//                    }
//
//                    itBehavesLike(RequesterGivenURLConverterSuccessAndURLSessionErrorBehavior.self) {
//                        .init(
//                            expectedError: expectedError,
//                            path: path,
//                            expectedRequestURL: expectedRequestURL,
//                            expectedTaskResult: sessionReturnTask,
//                            session: session,
//                            queues: queues,
//                            sut: sut
//                        )
//                    }
//
//                    itBehavesLike(UploaderGivenURLConverterSuccessAndURLSessionErrorBehavior.self) {
//                        .init(
//                            expectedError: expectedError,
//                            path: path,
//                            data: Data(),
//                            expectedRequestURL: expectedRequestURL,
//                            expectedTaskResult: sessionReturnTask,
//                            session: session,
//                            queues: queues,
//                            sut: sut
//                        )
//                    }
//
//                    itBehavesLike(DownloaderGivenURLConverterSuccessAndURLSessionErrorBehavior.self) {
//                        .init(
//                            expectedError: expectedError,
//                            path: path,
//                            expectedRequestURL: expectedRequestURL,
//                            expectedTaskResult: sessionReturnTask,
//                            session: session,
//                            queues: queues,
//                            sut: sut
//                        )
//                    }
//
//                }
//
//                describe("GIVEN a response with an invalid status code") {
//                    var invalidStatusReponse: HTTPURLResponse!
//                    var expectedError: NetworkerError!
//                    beforeEach {
//                        invalidStatusReponse = HTTPURLResponseStub(
//                            url: "https://www.any-url.com", statusCode: 400
//                        )
//                        expectedError = .response(
//                            .validator(.custom(StatusCodeDefaultValidatorError.client, invalidStatusReponse))
//                        )
//
//                        session.requestResultCompletion = { completion in
//                            completion(nil, invalidStatusReponse, nil)
//                        }
//
//                        session.uploadResultCompletion = { completion in
//                            completion(nil, invalidStatusReponse, nil)
//                        }
//
//                        session.downloadResultCompletion = { completion in
//                            completion(nil, invalidStatusReponse, nil)
//                        }
//                    }
//
//                    itBehavesLike(RequesterGivenURLConverterSuccessAndURLSessionErrorBehavior.self) {
//                        .init(
//                            expectedError: expectedError,
//                            path: path,
//                            expectedRequestURL: expectedRequestURL,
//                            expectedTaskResult: sessionReturnTask,
//                            session: session,
//                            queues: queues,
//                            sut: sut
//                        )
//                    }
//
//                    itBehavesLike(UploaderGivenURLConverterSuccessAndURLSessionErrorBehavior.self) {
//                        .init(
//                            expectedError: expectedError,
//                            path: path,
//                            data: Data(),
//                            expectedRequestURL: expectedRequestURL,
//                            expectedTaskResult: sessionReturnTask,
//                            session: session,
//                            queues: queues,
//                            sut: sut
//                        )
//                    }
//
//                    itBehavesLike(DownloaderGivenURLConverterSuccessAndURLSessionErrorBehavior.self) {
//                        .init(
//                            expectedError: expectedError,
//                            path: path,
//                            expectedRequestURL: expectedRequestURL,
//                            expectedTaskResult: sessionReturnTask,
//                            session: session,
//                            queues: queues,
//                            sut: sut
//                        )
//                    }
//
//                }
//
//                describe("GIVEN a valid response") {
//                    var validResponse: HTTPURLResponse!
//
//                    beforeEach {
//                        validResponse = HTTPURLResponseStub(
//                            url: "https://www.any-url.com",
//                            statusCode: 200,
//                            allHeaderFields: ["Accept-Content":"application/json"]
//                        )
//                    }
//
//                    describe("GIVEN a valid response with no data / fileURL") {
//                        var expectedRequestError: NetworkerError!
//                        var expectedUploadResult: NetworkUploaderResult!
//                        var expectedDownloadError: NetworkerError!
//                        beforeEach {
//                            expectedRequestError = .response(.emptyData)
//                            session.requestResultCompletion = { completion in
//                                completion(nil, validResponse, nil)
//                            }
//
//                            expectedUploadResult = .init(
//                                data: nil,
//                                statusCode: validResponse.statusCode,
//                                headerFields: validResponse.allHeaderFields
//                            )
//                            session.uploadResultCompletion = { completion in
//                                completion(nil, validResponse, nil)
//                            }
//
//                            expectedDownloadError = .download(.fileURLMissing)
//                            session.downloadResultCompletion = { completion in
//                                completion(nil, validResponse, nil)
//                            }
//                        }
//
//                        itBehavesLike(RequesterGivenURLConverterSuccessAndURLSessionErrorBehavior.self) {
//                            .init(
//                                expectedError: expectedRequestError,
//                                path: path,
//                                expectedRequestURL: expectedRequestURL,
//                                expectedTaskResult: sessionReturnTask,
//                                session: session,
//                                queues: queues,
//                                sut: sut
//                            )
//                        }
//
//                        itBehavesLike(UploaderGivenURLConverterAndURLSessionSuccessBehavior.self) {
//                            .init(
//                                expectedResult: expectedUploadResult,
//                                path: path,
//                                data: Data(),
//                                expectedRequestURL: expectedRequestURL,
//                                expectedTaskResult: sessionReturnTask,
//                                session: session,
//                                queues: queues,
//                                sut: sut
//                            )
//                        }
//
//                        itBehavesLike(DownloaderGivenURLConverterSuccessAndURLSessionErrorBehavior.self) {
//                            .init(
//                                expectedError: expectedDownloadError,
//                                path: path,
//                                expectedRequestURL: expectedRequestURL,
//                                expectedTaskResult: sessionReturnTask,
//                                session: session,
//                                queues: queues,
//                                sut: sut
//                            )
//                        }
//
//                    }
//
//                    describe("GIVEN a valid response with data / fileURl") {
//                        var data: Data!
//                        var fileURL: URL!
//                        var expectedRequestResult: NetworkRequesterResult!
//                        var expectedUploadResult: NetworkUploaderResult!
//                        var expectedDownloadResult: NetworkDownloaderResult!
//                        beforeEach {
//                            data = "{ }".data(using: .utf8)
//                            expectedRequestResult = .init(
//                                data: data,
//                                statusCode: validResponse.statusCode,
//                                headerFields: validResponse.allHeaderFields
//                            )
//                            session.requestResultCompletion = { completion in
//                                completion(data, validResponse, nil)
//                            }
//
//                            expectedUploadResult = .init(
//                                data: data,
//                                statusCode: validResponse.statusCode,
//                                headerFields: validResponse.allHeaderFields
//                            )
//                            session.uploadResultCompletion = { completion in
//                                completion(data, validResponse, nil)
//                            }
//
//                            fileURL = URL(string: "https://testing.com/")!
//                            expectedDownloadResult = .init(
//                                statusCode: validResponse.statusCode,
//                                headerFields: validResponse.allHeaderFields
//                            )
//                            session.downloadResultCompletion = { completion in
//                                completion(fileURL, validResponse, nil)
//                            }
//                        }
//
//                        itBehavesLike(RequesterGivenURLConverterAndURLSessionSuccessBehavior.self) {
//                            .init(
//                                expectedResult: expectedRequestResult,
//                                path: path,
//                                expectedRequestURL: expectedRequestURL,
//                                expectedTaskResult: sessionReturnTask,
//                                session: session,
//                                queues: queues,
//                                sut: sut
//                            )
//                        }
//
//                        itBehavesLike(UploaderGivenURLConverterAndURLSessionSuccessBehavior.self) {
//                            .init(
//                                expectedResult: expectedUploadResult,
//                                path: path,
//                                data: data,
//                                expectedRequestURL: expectedRequestURL,
//                                expectedTaskResult: sessionReturnTask,
//                                session: session,
//                                queues: queues,
//                                sut: sut
//                            )
//                        }
//
//                        itBehavesLike(DownloaderGivenURLConverterAndURLSessionSuccessBehavior.self) {
//                            .init(
//                                expectedResult: expectedDownloadResult,
//                                path: path,
//                                expectedFileHandlerURL: fileURL,
//                                expectedRequestURL: expectedRequestURL,
//                                expectedTaskResult: sessionReturnTask,
//                                session: session,
//                                queues: queues,
//                                sut: sut
//                            )
//                        }
//                    }
//                }
//            }
//        }
//    }
//}
