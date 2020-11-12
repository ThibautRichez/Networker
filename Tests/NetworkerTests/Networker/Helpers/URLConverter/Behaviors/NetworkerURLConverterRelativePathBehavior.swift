//
//  NetworkerURLConverterRelativePathBehavior.swift
//  
//
//  Created by RICHEZ Thibaut on 10/31/20.
//

import Foundation
import Quick
import Nimble
@testable import Networker

final class NetworkerURLConverterRelativePathBehavior: Behavior<NetworkerURLConverter> {
    override class func spec(_ aContext: @escaping () -> NetworkerURLConverter) {
        describe("GIVEN any relative path") {
            let path: String = "getPage?named=home"

            var components: NetworkerURLComponents!
            var urlConcatener: URLStringConcatenerMock!
            var sut: NetworkerURLConverter!
            beforeEach {
                sut = aContext()
                urlConcatener = (sut.urlConcatener as! URLStringConcatenerMock)
            }

            describe("GIVEN a nil baseURL") {
                beforeEach {
                    components = .init(baseURL: nil, path: path)
                }

                context("WHEN we try to make an url") {
                    it("THEN it should fail with a .baseURLMissing error") {
                        expect {
                            try sut.url(from: components)
                        }.to(throwError(NetworkerError.path(.baseURLMissing)))

                        expect(urlConcatener.didCallConcat).to(beFalse())
                    }
                }
            }

            describe("GIVEN an non absolute baseURL") {
                let invalidBaseURL = "www.ecosia.com"
                beforeEach {
                    components = .init(baseURL: invalidBaseURL, path: path)
                }

                context("WHEN we try to make an url") {
                    it("THEN it should fail with a .baseURLMissing error") {
                        expect {
                            try sut.url(from: components)
                        }.to(throwError(
                                NetworkerError.path(.invalidBaseURL(invalidBaseURL))
                        ))

                        expect(urlConcatener.didCallConcat).to(beFalse())
                    }
                }
            }

            describe("GIVEN an invalid absolute baseURL") {
                let invalidBaseURL = "https://www.#ecô$ìa=com"
                beforeEach {
                    components = .init(baseURL: invalidBaseURL, path: path)
                }

                context("WHEN we try to make an url") {
                    it("THEN it should fail with a .baseURLMissing error") {
                        expect {
                            try sut.url(from: components)
                        }.to(throwError(
                                NetworkerError.path(.invalidBaseURL(invalidBaseURL))
                        ))

                        expect(urlConcatener.didCallConcat).to(beFalse())
                    }
                }
            }

            describe("GIVEN a valid baseURL") {
                let validBaseURL = "https://www.ecosia.com"

                describe("GIVEN an URLStringConcatener that returns a valid string representation") {
                    let validConcatURL = "https://valid-result-url.com"
                    beforeEach {
                        components = .init(baseURL: validBaseURL, path: path)
                        urlConcatener.concatResult = { validConcatURL }
                    }

                    context("WHEN we try to make an url") {
                        it("THEN it should return an URL with the URLConcatener returned value") {
                            expect {
                                let url = try sut.url(from: components)

                                expect(url.absoluteString).to(equal(validConcatURL))
                                expect(urlConcatener.concatCallCount).to(equal(1))
                                expect(urlConcatener.concatArguments.count).to(equal(1))
                                let concatArgument = urlConcatener.concatArguments.first
                                expect(concatArgument?.value).to(equal(validBaseURL))
                                expect(concatArgument?.otherString).to(equal(path))
                            }.toNot(throwError())
                        }
                    }
                }

                describe("GIVEN an URLStringConcatener that returns an invalid string representation") {
                    let invalidConcatURL = "If only i was part of the valid ones"
                    beforeEach {
                        components = .init(
                            baseURL: validBaseURL, token: "12RGDTYTR", path: path
                        )
                        urlConcatener.concatResult = { invalidConcatURL }
                    }

                    context("WHEN we try to make an url") {
                        it("THEN it should fail with a .invalidRelativePath error") {
                            expect {
                                try sut.url(from: components)
                            }.to(throwError(
                                NetworkerError.path(.invalidRelativePath(path))
                            ))
                        }
                    }
                }
            }
        }
    }
}
