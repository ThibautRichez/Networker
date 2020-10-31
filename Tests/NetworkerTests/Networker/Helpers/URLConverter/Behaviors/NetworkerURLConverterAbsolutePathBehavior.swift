//
//  NetworkerURLConverterAbsolutePathBehavior.swift
//  
//
//  Created by RICHEZ Thibaut on 10/31/20.
//

import Foundation
import Quick
import Nimble
@testable import Networker

final class NetworkerURLConverterAbsolutePathBehavior: Behavior<NetworkerURLConverter> {
    override class func spec(_ aContext: @escaping () -> NetworkerURLConverter) {
        var urlConcatener: URLStringConcatenerMock!
        var sut: NetworkerURLConverter!
        beforeEach {
            sut = aContext()
            urlConcatener = (sut.urlConcatener as! URLStringConcatenerMock)
        }

        describe("GIVEN an invalid absolute path") {
            let invalidAbsolutePath = "https://coco-l'astico<}"
            let components = NetworkerURLComponents(path: invalidAbsolutePath)

            context("WHEN we try to make an url") {
                it("THEN it should fail with a .invalidAbsolutePath error") {
                    expect {
                        try sut.url(from: components)
                    }.to(throwError(
                            NetworkerError.path(.invalidAbsolutePath(invalidAbsolutePath))
                    ))

                    expect(urlConcatener.didCallConcat).to(beFalse())
                }
            }
        }

        describe("GIVEN a valid secure absolute path") {
            let validAbsolutePath = "https://testing.com"
            let components = NetworkerURLComponents(path: validAbsolutePath)

            context("WHEN we try to make an url") {
                it("THEN it should succeed") {
                    expect {
                        let url = try sut.url(from: components)
                        expect(url.absoluteString).to(equal(validAbsolutePath))
                    }.toNot(throwError())

                    expect(urlConcatener.didCallConcat).to(beFalse())
                }
            }
        }

        describe("GIVEN a valid insecure absolute path") {
            let validAbsolutePath = "http://testing.com"
            let components = NetworkerURLComponents(path: validAbsolutePath)

            context("WHEN we try to make an url") {
                it("THEN it should succeed") {
                    expect {
                        let url = try sut.url(from: components)
                        expect(url.absoluteString).to(equal(validAbsolutePath))
                    }.toNot(throwError())

                    expect(urlConcatener.didCallConcat).to(beFalse())
                }
            }
        }
    }
}
