//
//  NetworkRequesterTests.swift
//  
//
//  Created by RICHEZ Thibaut on 10/25/20.
//

import XCTest
import Quick
import Nimble
@testable import Networker

final class NetworkRequesterTests: QuickSpec {
    override func spec() {
        describe("GIVEN a URLSession mock") {
            var session: URLSessionMock!
            var sessionReader: NetworkerSessionConfigurationReaderMock!
            var sut: Networker!
            beforeEach {
                session = .init()
                sessionReader = .init()
                sut = .init(session: session, sessionReader: sessionReader)
            }

            describe("GIVEN a absolute path") {

                describe("GIVEN an invalid absolute path") {
                    let invalidAbsolutePath = "https://this-is!an$*invalid(formatted,><@&URL"

                    context("WHEN we call request") {
                        var task: URLSessionTaskMock?
                        var error: NetworkerError?

                        beforeEach {
                            waitUntil { (done) in
                                task = sut.requestError(path: invalidAbsolutePath) { (sutError) in
                                    error = sutError
                                    done()
                                }
                            }
                        }

                        it("THEN the error should be .invalidAbsolutePath") {
                            expect({ () -> ToSucceedResult in
                                guard case .path(.invalidAbsolutePath(invalidAbsolutePath)) = error else {
                                    return .failed(reason: "Expected .invalidAbsolutePath, got \(error)")
                                }

                                return .succeeded
                            }).to(succeed())

                            expect(task).to(beNil())

                            expect(session.didCallUpload).to(beFalse())
                            expect(session.didCallRequest).to(beFalse())
                            expect(session.didCallDownload).to(beFalse())
                            expect(session.didCallGetTasks).to(beFalse())
                        }
                    }
                }

                describe("GIVEN a valid absolute path") {
                    let validAbsoluteURL = "https://testing.com/"
                    itBehavesLike(AnyRequesterWithValidURL.self) {
                        .init(
                            url: validAbsoluteURL,
                            expectedRequestURL: validAbsoluteURL,
                            session: session,
                            sut: sut
                        )
                    }
                }
            }


            describe("GIVEN a relative path") {

                describe("GIVEN an invalid relative path") {
                    let invalidRelativePath = "iamNot-A%pathèto@&é*"
                    beforeEach {
                        sut.setBaseURL(to: "https://testing.com/")
                    }

                    context("WHEN we call request") {
                        var task: URLSessionTaskMock?
                        var error: NetworkerError?

                        beforeEach {
                            waitUntil { (done) in
                                task = sut.requestError(path: invalidRelativePath) { (sutError) in
                                    error = sutError
                                    done()
                                }
                            }
                        }

                        it("THEN the error should be .invalidRelativePath") {
                            expect({ () -> ToSucceedResult in
                                guard case .path(.invalidRelativePath(invalidRelativePath)) = error else {
                                    return .failed(reason: "Expected .invalidRelativePath, got \(error)")
                                }

                                return .succeeded
                            }).to(succeed())

                            expect(task).to(beNil())

                            expect(session.didCallUpload).to(beFalse())
                            expect(session.didCallRequest).to(beFalse())
                            expect(session.didCallDownload).to(beFalse())
                            expect(session.didCallGetTasks).to(beFalse())
                        }
                    }
                }

                describe("GIVEN a valid relative path") {
                    let relativePath = "getPage?pagename=home"

                    describe("GIVEN a nil baseURL in Networker configuration") {
                        beforeEach {
                            sut.setBaseURL(to: nil)
                        }

                        describe("GIVEN a nil baseURL in session configuration") {
                            beforeEach {
                                sessionReader.configurationResult = { .init(baseURL: nil) }
                            }

                            context("WHEN we call request") {
                                var task: URLSessionTaskMock?
                                var error: NetworkerError?

                                beforeEach {
                                    waitUntil { (done) in
                                        task = sut.requestError(path: relativePath) { (sutError) in
                                            error = sutError
                                            done()
                                        }
                                    }
                                }

                                it("THEN the error should be .baseURLMissing") {
                                    expect({ () -> ToSucceedResult in
                                        guard case .path(.baseURLMissing) = error else {
                                            return .failed(reason: "Expected .baseURLMissing, got \(error)")
                                        }

                                        return .succeeded
                                    }).to(succeed())

                                    expect(task).to(beNil())

                                    expect(session.didCallUpload).to(beFalse())
                                    expect(session.didCallRequest).to(beFalse())
                                    expect(session.didCallDownload).to(beFalse())
                                    expect(session.didCallGetTasks).to(beFalse())
                                }
                            }
                        }

                        describe("GIVEN a invalid baseURL in session configuration") {
                            let invalidBaseURL = "hjkiuhsj$^ù£"
                            beforeEach {
                                sessionReader.configurationResult = { .init(baseURL: invalidBaseURL) }
                            }

                            context("WHEN we call request") {
                                var task: URLSessionTaskMock?
                                var error: NetworkerError?

                                beforeEach {
                                    waitUntil { (done) in
                                        task = sut.requestError(path: relativePath) { (sutError) in
                                            error = sutError
                                            done()
                                        }
                                    }
                                }

                                it("THEN the error should be .invalidBaseURL") {
                                    expect({ () -> ToSucceedResult in
                                        guard case .path(.invalidBaseURL(let sutPathError)) = error else {
                                            return .failed(reason: "Expected .invalidBaseURL, got \(error)")
                                        }

                                        expect(sutPathError).to(equal(invalidBaseURL))
                                        return .succeeded
                                    }).to(succeed())

                                    expect(task).to(beNil())

                                    expect(session.didCallUpload).to(beFalse())
                                    expect(session.didCallRequest).to(beFalse())
                                    expect(session.didCallDownload).to(beFalse())
                                    expect(session.didCallGetTasks).to(beFalse())
                                }
                            }
                        }

                        describe("GIVEN a valid baseURL in session configuration") {
                            describe("GIVEN nil token") {
                                let validBaseURL = "https://testing.com/"
                                let expectResultURL = "\(validBaseURL)\(relativePath)"
                                beforeEach {
                                    sessionReader.configurationResult = {
                                        .init(token: nil, baseURL: validBaseURL)
                                    }
                                }

                                itBehavesLike(AnyRequesterWithValidURL.self) {
                                    .init(
                                        url: relativePath,
                                        expectedRequestURL: expectResultURL,
                                        session: session,
                                        sut: sut
                                    )
                                }
                            }

                            describe("GIVEN token") {
                                let validBaseURL = "https://testing.com/"
                                let token = "1234AZERTGVC"
                                let expectResultURL = "\(validBaseURL)\(token)/\(relativePath)"
                                beforeEach {
                                    sessionReader.configurationResult = {
                                        .init(token: token, baseURL: validBaseURL)
                                    }
                                }

                                itBehavesLike(AnyRequesterWithValidURL.self) {
                                    .init(
                                        url: relativePath,
                                        expectedRequestURL: expectResultURL,
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
    }
}


fileprivate struct AnyRequesterWithValidURLContext {
    var url: String
    var expectedRequestURL: String
    var session: URLSessionMock
    var sut: Networker
}

fileprivate final class AnyRequesterWithValidURL: Behavior<AnyRequesterWithValidURLContext> {
    override class func spec(_ aContext: @escaping () -> AnyRequesterWithValidURLContext) {
        describe("GIVEN a valid url with any URLSession and Networker ") {
            var url: String!
            var expectedRequestURL: String!
            var session: URLSessionMock!
            var sessionReturnTask: URLSessionTaskMock!
            var sut: Networker!
            beforeEach {
                url = aContext().url
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

                context("WHEN we call request") {
                    var task: URLSessionTaskMock?
                    var error: NetworkerError?

                    beforeEach {
                        waitUntil { (done) in
                            task = sut.requestError(path: url) { (sutError) in
                                error = sutError
                                done()
                            }
                        }
                    }

                    it("THEN the error should be .response(.empty)") {
                        expect({ () -> ToSucceedResult in
                            guard case .response(.empty) = error else {
                                return .failed(reason: "Expected .response(.empty), got \(error)")
                            }

                            return .succeeded
                        }).to(succeed())

                        expect(task).to(be(sessionReturnTask))
                        expect(task?.resumeCallCount).to(equal(1))
                        expect(task?.didCallCancel).to(beFalse())

                        expect(session.requestCallCount).to(equal(1))
                        expect(session.requestArguments.count).to(equal(1))
                        let requestURL = try! sut.makeURL(from: url)
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

            describe("GIVEN a session that returns an error") {
                var requestError: Error!
                beforeEach {
                    requestError = NSError(domain: "error.test", code: 10, userInfo: nil)
                    session.requestCompletion = { completion in
                        completion(nil, nil, requestError)
                    }
                }

                context("WHEN we call request") {
                    var task: URLSessionTaskMock?
                    var error: NetworkerError?

                    beforeEach {
                        waitUntil { (done) in
                            task = sut.requestError(path: url) { (sutError) in
                                error = sutError
                                done()
                            }
                        }
                    }

                    it("THEN the error should be .remote)") {
                        expect({ () -> ToSucceedResult in
                            guard case .remote(.unknown(let remoteError)) = error else {
                                return .failed(reason: "Expected .remote(.unknown), got \(error)")
                            }

                            expect(remoteError).to(matchError(requestError))
                            return .succeeded
                        }).to(succeed())

                        expect(task).to(be(sessionReturnTask))
                        expect(task?.resumeCallCount).to(equal(1))
                        expect(task?.didCallCancel).to(beFalse())

                        expect(session.requestCallCount).to(equal(1))
                        expect(session.requestArguments.count).to(equal(1))
                        let requestURL = try! sut.makeURL(from: url)
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

            describe("GIVEN a session that returns a reponse") {

                describe("GIVEN an invalid response (should be HTTPURLResponse)") {
                    var invalidReponse: URLResponse!
                    beforeEach {
                        invalidReponse = .init()
                        session.requestCompletion = { completion in
                            completion(nil, invalidReponse, nil)
                        }
                    }

                    context("WHEN we call request") {
                        var task: URLSessionTaskMock?
                        var error: NetworkerError?

                        beforeEach {
                            waitUntil { (done) in
                                task = sut.requestError(path: url) { (sutError) in
                                    error = sutError
                                    done()
                                }
                            }
                        }

                        it("THEN the error should be .response(.invalid)") {
                            expect({ () -> ToSucceedResult in
                                guard case .response(.invalid(let sutResponse)) = error else {
                                    return .failed(reason: "Expected .response(.invalid), got \(error)")
                                }

                                expect(sutResponse).to(be(invalidReponse))
                                return .succeeded
                            }).to(succeed())

                            expect(task).to(be(sessionReturnTask))
                            expect(task?.resumeCallCount).to(equal(1))
                            expect(task?.didCallCancel).to(beFalse())

                            expect(session.requestCallCount).to(equal(1))
                            expect(session.requestArguments.count).to(equal(1))
                            let requestURL = try! sut.makeURL(from: url)
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

                describe("GIVEN a response with an invalid status code") {
                    var invalidStatusReponse: HTTPURLResponse!

                    beforeEach {

                        invalidStatusReponse = HTTPURLResponseStub(url: url, statusCode: 400)
                        session.requestCompletion = { completion in
                            completion(nil, invalidStatusReponse, nil)
                        }
                    }

                    context("WHEN we call request") {
                        var task: URLSessionTaskMock?
                        var error: NetworkerError?

                        beforeEach {
                            waitUntil { (done) in
                                task = sut.requestError(path: url) { (sutError) in
                                    error = sutError
                                    done()
                                }
                            }
                        }

                        it("THEN the error should be .response(.statusCode)") {
                            expect({ () -> ToSucceedResult in
                                guard case .response(.statusCode(let sutResponse)) = error else {
                                    return .failed(reason: "Expected .response(.invalid), got \(error)")
                                }

                                expect(sutResponse).to(be(invalidStatusReponse))
                                return .succeeded
                            }).to(succeed())

                            expect(task).to(be(sessionReturnTask))
                            expect(task?.resumeCallCount).to(equal(1))
                            expect(task?.didCallCancel).to(beFalse())

                            expect(session.requestCallCount).to(equal(1))
                            expect(session.requestArguments.count).to(equal(1))
                            let requestURL = try! sut.makeURL(from: url)
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

                describe("GIVEN a response with an invalid MimeType") {
                    let invalidMimeType = "invalid-mime-type"
                    var invalidMimeTypeReponse: HTTPURLResponse!

                    beforeEach {
                        invalidMimeTypeReponse = HTTPURLResponseStub(
                            url: url,
                            statusCode: 200,
                            mimeType: invalidMimeType
                        )
                        session.requestCompletion = { completion in
                            completion(nil, invalidMimeTypeReponse, nil)
                        }
                    }

                    context("WHEN we call request") {
                        var task: URLSessionTaskMock?
                        var error: NetworkerError?

                        beforeEach {
                            waitUntil { (done) in
                                task = sut.requestError(path: url) { (sutError) in
                                    error = sutError
                                    done()
                                }
                            }
                        }

                        it("THEN the error should be .response(.invalidMimeType)") {
                            expect({ () -> ToSucceedResult in
                                guard case .response(.invalidMimeType(let passed, let allowed)) = error else {
                                    return .failed(reason: "Expected .response(.invalidMimeType), got \(error)")
                                }

                                expect(passed).to(equal(invalidMimeType))
                                expect(allowed).to(equal(sut.acceptableMimeTypes.map { $0.rawValue }))
                                return .succeeded
                            }).to(succeed())

                            expect(task).to(be(sessionReturnTask))
                            expect(task?.resumeCallCount).to(equal(1))
                            expect(task?.didCallCancel).to(beFalse())

                            expect(session.requestCallCount).to(equal(1))
                            expect(session.requestArguments.count).to(equal(1))
                            let requestURL = try! sut.makeURL(from: url)
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

                describe("GIVEN a valid response") {
                    var validResponse: HTTPURLResponse!

                    beforeEach {
                        validResponse = HTTPURLResponseStub(
                            url: url,
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

                        context("WHEN we call request") {
                            var task: URLSessionTaskMock?
                            var error: NetworkerError?

                            beforeEach {
                                waitUntil { (done) in
                                    task = sut.requestError(path: url) { (sutError) in
                                        error = sutError
                                        done()
                                    }
                                }
                            }

                            it("THEN the error should be .response(.empty)") {
                                expect({ () -> ToSucceedResult in
                                    guard case .response(.empty) = error else {
                                        return .failed(reason: "Expected .response(.empty), got \(error)")
                                    }

                                    return .succeeded
                                }).to(succeed())

                                expect(task).to(be(sessionReturnTask))
                                expect(task?.resumeCallCount).to(equal(1))
                                expect(task?.didCallCancel).to(beFalse())

                                expect(session.requestCallCount).to(equal(1))
                                expect(session.requestArguments.count).to(equal(1))
                                let requestURL = try! sut.makeURL(from: url)
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
                                    task = sut.requestSuccess(path: url) { (sutResult) in
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
                                let requestURL = try! sut.makeURL(from: url)
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


