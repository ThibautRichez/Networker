//
//  NetworkerURLStringConcatenerTests.swift
//  
//
//  Created by RICHEZ Thibaut on 10/30/20.
//

import Foundation
import Quick
import Nimble
@testable import Networker

final class NetworkerURLStringConcatenerTests: QuickSpec {
    override func spec() {
        describe("GIVEN a SUT") {
            var sut: NetworkerURLStringConcatener!
            beforeEach {
                sut = .init()
            }

            describe("GIVEN two values that don't have '/' delimiter") {
                let firstValue = "https://base-url.com"
                let secondValue = "getPage?named=home"

                context("WHEN we concat them") {
                    var result: String!
                    beforeEach {
                        result = sut.concat(firstValue, with: secondValue)
                    }

                    it("THEN it should add a delimiter between them") {
                        expect(result).to(equal("\(firstValue)/\(secondValue)"))
                    }
                }
            }

            describe("GIVEN a first value that have a delimiter and a second that doesn't") {
                let firstValue = "https://base-url.com/"
                let secondValue = "getPage?named=home"

                context("WHEN we concat them") {
                    var result: String!
                    beforeEach {
                        result = sut.concat(firstValue, with: secondValue)
                    }

                    it("THEN it should just combine the string") {
                        expect(result).to(equal(firstValue + secondValue))
                    }
                }
            }

            describe("GIVEN a first value that doesn't have a delimiter and a second that does") {
                let firstValue = "https://base-url.com"
                let secondValue = "/getPage?named=home"

                context("WHEN we concat them") {
                    var result: String!
                    beforeEach {
                        result = sut.concat(firstValue, with: secondValue)
                    }

                    it("THEN it should just combine the string") {
                        expect(result).to(equal(firstValue + secondValue))
                    }
                }
            }

            describe("GIVEN two values that have a delimiter") {
                let firstValue = "https://base-url.com/"
                let secondValue = "/getPage?named=home"

                context("WHEN we concat them") {
                    var result: String!
                    beforeEach {
                        result = sut.concat(firstValue, with: secondValue)
                    }

                    it("THEN it have only one delimiter") {
                        expect(result).to(equal("\(firstValue)\(secondValue.dropFirst())"))
                    }
                }
            }
        }
    }
}
