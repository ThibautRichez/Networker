//
//  NetworkerSessionConfigurationRepositoryTests.swift
//  
//
//  Created by RICHEZ Thibaut on 11/13/20.
//

import Foundation
import Quick
import Nimble
@testable import Networker

final class NetworkerSessionConfigurationRepositoryTests: QuickSpec {
    override func spec() {
        describe("GIVEN a mock UserDefaults") {
            var defaults: UserDefaults!
            var sut: NetworkerSessionConfigurationRepository!
            beforeEach {
                defaults = UserDefaults(suiteName: #file)
                defaults.removePersistentDomain(forName: #file)

                sut = .init(defaults: defaults)
            }

            describe("GIVEN an empty UserDefaults") {

                context("WHEN we retrieve the configuration") {
                    var configuration: NetworkerSessionConfiguration!
                    beforeEach {
                        configuration = sut.configuration
                    }

                    it("THEN all its properties should be nil") {
                        expect(configuration.baseURL).to(beNil())
                        expect(configuration.token).to(beNil())
                    }
                }

                context("WHEN we retrieve the value of the baseURL and token") {

                    context("WHEN we doesn't specify a default value") {
                        var baseURL: String?
                        var token: String?
                        beforeEach {
                            baseURL = sut.value(forKey: .baseURL)
                            token = sut.value(forKey: .token)
                        }

                        it("THEN they should both be nil") {
                            expect(baseURL).to(beNil())
                            expect(token).to(beNil())
                        }
                    }

                    context("WHEN we specify a default value") {
                        var baseURL: String?
                        let baseURLDefault = "https://testing.com/"
                        var token: String?
                        let tokenDefault = "AZERT5434567"
                        beforeEach {
                            baseURL = sut.value(forKey: .baseURL, default: baseURLDefault)
                            token = sut.value(forKey: .token, default: tokenDefault)
                        }

                        it("THEN they should both have the default value") {
                            expect(baseURL).to(equal(baseURLDefault))
                            expect(token).to(equal(tokenDefault))
                        }
                    }
                }

            }

            describe("GIVEN a UserDefaults with values") {
                let sutBaseURL = "https://testing.com"
                let sutToken = "DRFTGYUHIJO9876543"
                beforeEach {
                    sut.setValue(value: sutBaseURL, forKey: .baseURL)
                    sut.setValue(value: sutToken, forKey: .token)
                }

                context("WHEN we retrieve the configuration") {
                    var configuration: NetworkerSessionConfiguration!
                    beforeEach {
                        configuration = sut.configuration
                    }

                    it("THEN the values should be equals to one set by the SUT") {
                        expect(configuration.baseURL).to(equal(sutBaseURL))
                        expect(configuration.token).to(equal(sutToken))
                    }
                }

                context("WHEN we retrieve the value of the baseURL and token") {

                    context("WHEN we doesn't specify a default value") {

                        context("WHEN we use an unexpected type") {
                            var baseURL: Int?
                            var token: Int?
                            beforeEach {
                                baseURL = sut.value(forKey: .baseURL)
                                token = sut.value(forKey: .token)
                            }

                            it("THEN they should both be nil") {
                                expect(baseURL).to(beNil())
                                expect(token).to(beNil())
                            }
                        }

                        context("WHEN we use the expected type") {
                            var baseURL: String?
                            var token: String?
                            beforeEach {
                                baseURL = sut.value(forKey: .baseURL)
                                token = sut.value(forKey: .token)
                            }

                            it("THEN the values should be equals to one set by the SUT") {
                                expect(baseURL).to(equal(sutBaseURL))
                                expect(token).to(equal(sutToken))
                            }
                        }
                    }

                    context("WHEN we specify a default value") {

                        context("WHEN we use an unexpected type") {
                            var baseURL: Int?
                            let baseURLDefault = 12
                            var token: Int?
                            let tokenDefault = 22
                            beforeEach {
                                baseURL = sut.value(forKey: .baseURL, default: baseURLDefault)
                                token = sut.value(forKey: .token, default: tokenDefault)
                            }

                            it("THEN they should both have the default value") {
                                expect(baseURL).to(equal(baseURLDefault))
                                expect(token).to(equal(tokenDefault))
                            }
                        }

                        context("WHEN we use the expected type") {
                            var baseURL: String?
                            let baseURLDefault = "https://testing.com/"
                            var token: String?
                            let tokenDefault = "AZERT5434567"
                            beforeEach {
                                baseURL = sut.value(forKey: .baseURL, default: baseURLDefault)
                                token = sut.value(forKey: .token, default: tokenDefault)
                            }

                            it("THEN the values should be equals to one set by the SUT") {
                                expect(baseURL).to(equal(sutBaseURL))
                                expect(token).to(equal(sutToken))
                            }
                        }
                    }
                }
            }
        }
    }
}
