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
                    session.requestCompletion = { completion in
                        completion(nil, nil, nil)
                    }
                }

                itBehavesLike(RequesterWithValidURLSessionError.self) {
                    .init(
                        expectedError: .response(.empty),
                        path: path,
                        expectedRequestURL: expectedRequestURL,
                        expectedErrorExecutorReturn: sessionReturnTask,
                        session: session,
                        errorExecutor: sut.requestError(path:completion:),
                        sut: sut
                    )
                }

            }

            describe("GIVEN a session that returns an error") {
                var requestError: Error!
                beforeEach {
                    requestError = NSError(domain: "error.test", code: 10, userInfo: nil)
                    session.requestCompletion = { completion in
                        completion(nil, nil, requestError)
                    }
                }

                itBehavesLike(RequesterWithValidURLSessionError.self) {
                    .init(
                        expectedError: .remote(.unknown(requestError)),
                        path: path,
                        expectedRequestURL: expectedRequestURL,
                        expectedErrorExecutorReturn: sessionReturnTask,
                        session: session,
                        errorExecutor: sut.requestError(path:completion:),
                        sut: sut
                    )
                }

            }

            describe("GIVEN a session that returns a reponse") {

                describe("GIVEN an invalid response (should be HTTPURLResponse)") {
                    var invalidReponse: URLResponse!
                    beforeEach {
                        invalidReponse = .init()
                        session.requestCompletion = { completion in
                            completion(nil, invalidReponse, nil)
                        }
                    }

                    itBehavesLike(RequesterWithValidURLSessionError.self) {
                        .init(
                            expectedError: .response(.invalid(invalidReponse)),
                            path: path,
                            expectedRequestURL: expectedRequestURL,
                            expectedErrorExecutorReturn: sessionReturnTask,
                            session: session,
                            errorExecutor: sut.requestError(path:completion:),
                            sut: sut
                        )
                    }

                }

                describe("GIVEN a response with an invalid status code") {
                    var invalidStatusReponse: HTTPURLResponse!
                    beforeEach {
                        invalidStatusReponse = HTTPURLResponseStub(url: path, statusCode: 400)
                        session.requestCompletion = { completion in
                            completion(nil, invalidStatusReponse, nil)
                        }
                    }

                    itBehavesLike(RequesterWithValidURLSessionError.self) {
                        .init(
                            expectedError: .response(
                                .statusCode(invalidStatusReponse)
                            ),
                            path: path,
                            expectedRequestURL: expectedRequestURL,
                            expectedErrorExecutorReturn: sessionReturnTask,
                            session: session,
                            errorExecutor: sut.requestError(path:completion:),
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
                        session.requestCompletion = { completion in
                            completion(nil, invalidMimeTypeReponse, nil)
                        }
                    }

                    itBehavesLike(RequesterWithValidURLSessionError.self) {
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
                            errorExecutor: sut.requestError(path:completion:),
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
                            session.requestCompletion = { completion in
                                completion(nil, validResponse, nil)
                            }
                        }

                        itBehavesLike(RequesterWithValidURLSessionError.self) {
                            .init(
                                expectedError: .response(.empty),
                                path: path,
                                expectedRequestURL: expectedRequestURL,
                                expectedErrorExecutorReturn: sessionReturnTask,
                                session: session,
                                errorExecutor: sut.requestError(path:completion:),
                                sut: sut
                            )
                        }

                    }

                    describe("GIVEN a valid response with data") {
                        var data: Data!
                        beforeEach {
                            data = Data([1])
                            session.requestCompletion = { completion in
                                completion(data, validResponse, nil)
                            }
                        }

                        context("WHEN we call request") {
                            var task: URLSessionTaskMock?
                            var result: NetworkRequesterResult?

                            beforeEach {
                                waitUntil { (done) in
                                    task = sut.requestSuccess(path: path) { (sutResult) in
                                        result = sutResult
                                        done()
                                    }
                                }
                            }

                            it("THEN it should return a valid result") {
                                expect(result).toNot(beNil())
                                expect(result?.data).to(equal(data))
                                expect(result?.statusCode).to(equal(validResponse.statusCode))
                                expect(result?.headerFields.keys).to(equal(validResponse.allHeaderFields.keys))

                                expect(task).to(be(sessionReturnTask))
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
                            }
                        }
                    }
                }
            }
        }
    }
}
