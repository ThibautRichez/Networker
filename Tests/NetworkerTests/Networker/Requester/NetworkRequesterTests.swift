//
//  NetworkRequesterTests.swift
//  
//
//  Created by RICHEZ Thibaut on 10/25/20.
//

import Foundation
import Quick
import Nimble
@testable import Networker

final class NetworkRequesterTests: QuickSpec {
    override func spec() {
        describe("GIVEN a URLSession mock and a SessionConfigurationReader") {
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

                    itBehavesLike(NetworkerWithPathErrorBehavior.self) {
                        .init(
                            path: invalidAbsolutePath,
                            expectedError: .path(
                                .invalidAbsolutePath(invalidAbsolutePath)
                            ),
                            session: session,
                            errorExecutor: sut.requestError(path:completion:)
                        )
                    }

                }

                describe("GIVEN a valid absolute path") {
                    let validAbsoluteURL = "https://testing.com/"

                    itBehavesLike(RequesterWithValidURLBehavior.self) {
                        .init(
                            path: validAbsoluteURL,
                            expectedRequestURL: validAbsoluteURL,
                            session: session,
                            sut: sut
                        )
                    }

                }
            }


            describe("GIVEN a relative path") {

                describe("GIVEN an invalid relative path with valid baseURL") {
                    let invalidRelativePath = "iamNot-A%pathèto@&é*"
                    beforeEach {
                        sut.setBaseURL(to: "https://testing.com/")
                    }

                    itBehavesLike(NetworkerWithPathErrorBehavior.self) {
                        .init(
                            path: invalidRelativePath,
                            expectedError: .path(
                                .invalidRelativePath(invalidRelativePath)
                            ),
                            session: session,
                            errorExecutor: sut.requestError(path:completion:)
                        )
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

                            itBehavesLike(NetworkerWithPathErrorBehavior.self) {
                                .init(
                                    path: relativePath,
                                    expectedError: .path(.baseURLMissing),
                                    session: session,
                                    errorExecutor: sut.requestError(path:completion:)
                                )
                            }

                        }

                        describe("GIVEN a invalid baseURL in session configuration") {
                            let invalidBaseURL = "hjkiuhsj$^ù£"
                            beforeEach {
                                sessionReader.configurationResult = { .init(baseURL: invalidBaseURL) }
                            }

                            itBehavesLike(NetworkerWithPathErrorBehavior.self) {
                                .init(
                                    path: relativePath,
                                    expectedError: .path(
                                        .invalidBaseURL(invalidBaseURL)
                                    ),
                                    session: session,
                                    errorExecutor: sut.requestError(path:completion:)
                                )
                            }
                        }

                        describe("GIVEN a valid baseURL in session configuration") {
                            let validBaseURL = "https://testing.com/"

                            describe("GIVEN nil token") {
                                let expectResultURL = "\(validBaseURL)\(relativePath)"
                                beforeEach {
                                    sessionReader.configurationResult = {
                                        .init(token: nil, baseURL: validBaseURL)
                                    }
                                }

                                itBehavesLike(RequesterWithValidURLBehavior.self) {
                                    .init(
                                        path: relativePath,
                                        expectedRequestURL: expectResultURL,
                                        session: session,
                                        sut: sut
                                    )
                                }
                            }
                            // TODO: test with different path ending
                            // (with/without opening/closing slash)
                            describe("GIVEN token") {
                                let token = "1234AZERTGVC"
                                let expectResultURL = "\(validBaseURL)\(token)/\(relativePath)"
                                beforeEach {
                                    sessionReader.configurationResult = {
                                        .init(token: token, baseURL: validBaseURL)
                                    }
                                }

                                itBehavesLike(RequesterWithValidURLBehavior.self) {
                                    .init(
                                        path: relativePath,
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
