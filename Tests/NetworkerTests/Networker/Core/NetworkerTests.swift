////
////  NetworkerTests.swift
////  
////
////  Created by RICHEZ Thibaut on 10/25/20.
////
//
//import Foundation
//import Quick
//import Nimble
//@testable import Networker
//
//final class NetworkerTests: QuickSpec {
//    override func spec() {
//        describe("GIVEN any path and dependencies mocks") {
//            let anyPath = "Doesn't impact the core functionnality when mocking URLConverter"
//            var session: URLSessionMock!
//            var queues: NetworkerQueuesMock!
//            var sessionReader: NetworkerSessionConfigurationReaderMock!
//            var urlConverter: URLConverterMock!
//            var sut: Networker!
//            beforeEach {
//                session = .init()
//                sessionReader = .init()
//                queues = .init()
//                urlConverter = .init()
//                sut = .init(
//                    session: session,
//                    queues: queues,
//                    sessionReader: sessionReader,
//                    urlConverter: urlConverter
//                )
//            }
//
//            itBehavesLike(NetworkerURLComponentsBehavior.self) {
//                .init(
//                    sessionReader: sessionReader,
//                    urlConverter: urlConverter,
//                    sut: sut
//                )
//            }
//
//            describe("GIVEN a URLConverter that throws an error") {
//
//                describe("GIVEN a NetworkerError") {
//                    let converterError: NetworkerError = .path(.baseURLMissing)
//                    beforeEach {
//                        urlConverter.urlResult = { throw converterError }
//                    }
//
//                    itBehavesLike(NetworkerGivenURLConverterErrorBehavior.self) {
//                        .init(
//                            path: anyPath,
//                            expectedError: converterError,
//                            session: session,
//                            queues: queues,
//                            networker: sut
//                        )
//                    }
//                }
//
//                describe("GIVEN any other error than NetworkerError") {
//                    let converterError = NSError(domain: "error.testing", code: 12, userInfo: nil)
//                    beforeEach {
//                        urlConverter.urlResult = { throw converterError }
//                    }
//
//                    itBehavesLike(NetworkerGivenURLConverterErrorBehavior.self) {
//                        .init(
//                            path: anyPath,
//                            expectedError: .unknown(converterError),
//                            session: session,
//                            queues: queues,
//                            networker: sut
//                        )
//                    }
//                }
//            }
//
//            describe("GIVEN a URLConverter that returns an URL") {
//                let converterURL = "https://testing-url.com"
//                beforeEach {
//                    urlConverter.urlResult = { URL(string: converterURL)! }
//                }
//
//                itBehavesLike(NetworkerGivenURLConverterSuccessBehavior.self) {
//                    .init(
//                        path: converterURL,
//                        expectedRequestURL: converterURL,
//                        session: session,
//                        queues: queues,
//                        sut: sut
//                    )
//                }
//            }
//        }
//    }
//}
