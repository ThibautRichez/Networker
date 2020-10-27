//
//  RequesterWithValidURLBehavior.swift
//  
//
//  Created by RICHEZ Thibaut on 10/27/20.
//

import Foundation
import Quick
import Nimble
@testable import Networker

struct RequesterWithValidURLBehaviorContext {
    var path: String
    var expectedRequestURL: String
    var session: URLSessionMock
    var sut: Networker
}

final class RequesterWithValidURLBehavior: Behavior<RequesterWithValidURLBehaviorContext> {
    override class func spec(_ aContext: @escaping () -> RequesterWithValidURLBehaviorContext) {
        describe("GIVEN a valid url with any URLSession and Networker ") {
            var path: String!
            var expectedRequestURL: String!
            var session: URLSessionMock!
            var sessionReturnTask: URLSessionTaskMock!
            var sut: Networker!
            beforeEach {
                path = aContext().path
                expectedRequestURL = aContext().expectedRequestURL
                session = aContext().session
                sessionReturnTask = URLSessionTaskMock()
                session.requestResult = { sessionReturnTask }
                sut = aContext().sut
            }

            describe("GIVEN a session with an empty response") {
                beforeEach {
                    session.requestResultCompletion = { completion in
                        completion(nil, nil, nil)
                    }
                }

                itBehavesLike(RequesterWithValidURLSessionErrorBehavior.self) {
                    .init(
                        expectedError: .response(.empty),
                        path: path,
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
                    session.requestResultCompletion = { completion in
                        completion(nil, nil, requestError)
                    }
                }

                itBehavesLike(RequesterWithValidURLSessionErrorBehavior.self) {
                    .init(
                        expectedError: .remote(.unknown(requestError)),
                        path: path,
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
                        session.requestResultCompletion = { completion in
                            completion(nil, invalidReponse, nil)
                        }
                    }

                    itBehavesLike(RequesterWithValidURLSessionErrorBehavior.self) {
                        .init(
                            expectedError: .response(.invalid(invalidReponse)),
                            path: path,
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
                        session.requestResultCompletion = { completion in
                            completion(nil, invalidStatusReponse, nil)
                        }
                    }

                    itBehavesLike(RequesterWithValidURLSessionErrorBehavior.self) {
                        .init(
                            expectedError: .response(
                                .statusCode(invalidStatusReponse)
                            ),
                            path: path,
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
                        session.requestResultCompletion = { completion in
                            completion(nil, invalidMimeTypeReponse, nil)
                        }
                    }

                    itBehavesLike(RequesterWithValidURLSessionErrorBehavior.self) {
                        .init(
                            expectedError: .response(
                                .invalidMimeType(
                                    got: invalidMimeType,
                                    allowed: sut.acceptableMimeTypes.map { $0.rawValue }
                                )
                            ),
                            path: path,
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
                            session.requestResultCompletion = { completion in
                                completion(nil, validResponse, nil)
                            }
                        }

                        itBehavesLike(RequesterWithValidURLSessionErrorBehavior.self) {
                            .init(
                                expectedError: .response(.empty),
                                path: path,
                                expectedRequestURL: expectedRequestURL,
                                expectedErrorExecutorReturn: sessionReturnTask,
                                session: session,
                                sut: sut
                            )
                        }

                    }

                    describe("GIVEN a valid response with data") {
                        var data: Data!
                        beforeEach {
                            data = Data([1])
                            session.requestResultCompletion = { completion in
                                completion(data, validResponse, nil)
                            }
                        }

                        itBehavesLike(RequesterWithValidURLSessionSuccessBehavior.self) {
                            .init(
                                expectedResult: .init(
                                    data: data,
                                    statusCode: validResponse.statusCode,
                                    headerFields: validResponse.allHeaderFields
                                ),
                                path: path,
                                expectedRequestURL: expectedRequestURL,
                                expectedErrorExecutorReturn: sessionReturnTask,
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
