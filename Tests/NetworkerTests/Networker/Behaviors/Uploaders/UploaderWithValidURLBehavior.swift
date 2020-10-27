//
//  UploaderWithValidURLBehavior.swift
//  
//
//  Created by RICHEZ Thibaut on 10/27/20.
//

import Foundation
import Quick
import Nimble
@testable import Networker

struct UploaderWithValidURLBehaviorContext {
    var path: String
    var type: NetworkUploaderType = .post
    var data: Data?
    var expectedRequestURL: String
    var session: URLSessionMock
    var sut: Networker
}

final class UploaderWithValidURLBehavior: Behavior<UploaderWithValidURLBehaviorContext> {
    override class func spec(_ aContext: @escaping () -> UploaderWithValidURLBehaviorContext) {
        describe("GIVEN a valid url with any URLSession and Networker ") {
            var path: String!
            var type: NetworkUploaderType = .post
            var data: Data?
            var expectedRequestURL: String!
            var session: URLSessionMock!
            var sessionReturnTask: URLSessionTaskMock!
            var sut: Networker!
            beforeEach {
                path = aContext().path
                type = aContext().type
                data = aContext().data
                expectedRequestURL = aContext().expectedRequestURL
                session = aContext().session
                sessionReturnTask = URLSessionTaskMock()
                session.requestResult = { sessionReturnTask }
                sut = aContext().sut
            }

            describe("GIVEN a session with an empty response") {
                beforeEach {
                    session.uploadResultCompletion = { completion in
                        completion(nil, nil, nil)
                    }
                }

                itBehavesLike(UploaderWithValidURLSessionErrorBehavior.self) {
                    .init(
                        expectedError: .response(.empty),
                        path: path,
                        type: type,
                        data: data,
                        expectedRequestURL: expectedRequestURL,
                        expectedErrorExecutorReturn: sessionReturnTask,
                        session: session,
                        sut: sut
                    )
                }

            }

            describe("GIVEN a session that returns an error") {
                var requestError: Error!
                beforeEach {
                    requestError = NSError(domain: "error.test", code: 10, userInfo: nil)
                    session.uploadResultCompletion = { completion in
                        completion(nil, nil, requestError)
                    }
                }

                itBehavesLike(UploaderWithValidURLSessionErrorBehavior.self) {
                    .init(
                        expectedError: .remote(.unknown(requestError)),
                        path: path,
                        type: type,
                        data: data,
                        expectedRequestURL: expectedRequestURL,
                        expectedErrorExecutorReturn: sessionReturnTask,
                        session: session,
                        sut: sut
                    )
                }

            }

            describe("GIVEN a session that returns a reponse") {

                describe("GIVEN an invalid response (should be HTTPURLResponse)") {
                    var invalidReponse: URLResponse!
                    beforeEach {
                        invalidReponse = .init()
                        session.uploadResultCompletion = { completion in
                            completion(nil, invalidReponse, nil)
                        }
                    }

                    itBehavesLike(UploaderWithValidURLSessionErrorBehavior.self) {
                        .init(
                            expectedError: .response(.invalid(invalidReponse)),
                            path: path,
                            type: type,
                            data: data,
                            expectedRequestURL: expectedRequestURL,
                            expectedErrorExecutorReturn: sessionReturnTask,
                            session: session,
                            sut: sut
                        )
                    }

                }

                describe("GIVEN a response with an invalid status code") {
                    var invalidStatusReponse: HTTPURLResponse!
                    beforeEach {
                        invalidStatusReponse = HTTPURLResponseStub(url: path, statusCode: 400)
                        session.uploadResultCompletion = { completion in
                            completion(nil, invalidStatusReponse, nil)
                        }
                    }

                    itBehavesLike(UploaderWithValidURLSessionErrorBehavior.self) {
                        .init(
                            expectedError: .response(
                                .statusCode(invalidStatusReponse)
                            ),
                            path: path,
                            type: type,
                            data: data,
                            expectedRequestURL: expectedRequestURL,
                            expectedErrorExecutorReturn: sessionReturnTask,
                            session: session,
                            sut: sut
                        )
                    }

                }

                describe("GIVEN a response with an invalid MimeType") {
                    let invalidMimeType = "invalid-mime-type"
                    var invalidMimeTypeReponse: HTTPURLResponse!

                    beforeEach {
                        invalidMimeTypeReponse = HTTPURLResponseStub(
                            url: path,
                            statusCode: 200,
                            mimeType: invalidMimeType
                        )
                        session.uploadResultCompletion = { completion in
                            completion(nil, invalidMimeTypeReponse, nil)
                        }
                    }

                    itBehavesLike(UploaderWithValidURLSessionErrorBehavior.self) {
                        .init(
                            expectedError: .response(
                                .invalidMimeType(
                                    got: invalidMimeType,
                                    allowed: sut.acceptableMimeTypes.map { $0.rawValue }
                                )
                            ),
                            path: path,
                            type: type,
                            data: data,
                            expectedRequestURL: expectedRequestURL,
                            expectedErrorExecutorReturn: sessionReturnTask,
                            session: session,
                            sut: sut
                        )
                    }

                }

                describe("GIVEN a valid response") {
                    var validResponse: HTTPURLResponse!

                    beforeEach {
                        validResponse = HTTPURLResponseStub(
                            url: path,
                            statusCode: 200,
                            allHeaderFields: ["Accept-Content":"application/json"],
                            mimeType: sut.acceptableMimeTypes.first?.rawValue
                        )
                    }

                    describe("GIVEN a valid response with no data") {
                        beforeEach {
                            session.uploadResultCompletion = { completion in
                                completion(nil, validResponse, nil)
                            }
                        }

                        itBehavesLike(UploaderWithValidURLSessionSuccessBehavior.self) {
                            .init(
                                expectedResult: .init(
                                    data: nil,
                                    statusCode: validResponse.statusCode,
                                    headerFields: validResponse.allHeaderFields
                                ),
                                path: path,
                                type: type,
                                data: data,
                                expectedRequestURL: expectedRequestURL,
                                expectedReturnTask: sessionReturnTask,
                                session: session,
                                sut: sut
                            )
                        }

                    }

                    describe("GIVEN a valid response with data") {
                        var data: Data!
                        beforeEach {
                            data = Data([1])
                            session.uploadResultCompletion = { completion in
                                completion(data, validResponse, nil)
                            }
                        }

                        itBehavesLike(UploaderWithValidURLSessionSuccessBehavior.self) {
                            .init(
                                expectedResult: .init(
                                    data: data,
                                    statusCode: validResponse.statusCode,
                                    headerFields: validResponse.allHeaderFields
                                ),
                                path: path,
                                type: type,
                                data: data,
                                expectedRequestURL: expectedRequestURL,
                                expectedReturnTask: sessionReturnTask,
                                session: session,
                                sut: sut
                            )
                        }

                    }
                }
            }
        }
    }
}
