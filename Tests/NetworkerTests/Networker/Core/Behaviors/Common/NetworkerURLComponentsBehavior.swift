//
//  NetworkerURLComponentsBehavior.swift
//  
//
//  Created by RICHEZ Thibaut on 10/31/20.
//

import Foundation
import Quick
import Nimble
@testable import Networker

struct NetworkerURLComponentsContext {
    let sessionReader: NetworkerSessionConfigurationReaderMock
    let urlConverter: URLConverterMock
    let sut: Networker
}

final class NetworkerURLComponentsBehavior: Behavior<NetworkerURLComponentsContext> {
    override class func spec(_ aContext: @escaping () -> NetworkerURLComponentsContext) {
        let anyPath = "This value is needed but is irrelevant in this test suite."

        var sessionReader: NetworkerSessionConfigurationReaderMock!
        var urlConverter: URLConverterMock!
        var sut: Networker!
        beforeEach {
            let context = aContext()
            sessionReader = context.sessionReader
            urlConverter = context.urlConverter
            sut = context.sut
        }

        describe("GIVEN a sut configuration without a baseURL and token") {
            beforeEach {
                sut.set(baseURL: nil)
                sut.set(token: nil)
            }

            describe("GIVEN a session configuration without a baseURL and token") {
                beforeEach {
                    sessionReader.configurationResult = { .init(token: nil, baseURL: nil) }
                }

                context("WHEN we call request, upload and download") {
                    beforeEach {
                        waitUntil { (done) in
                            self.requestUploadAndDownload(
                                with: sut, path: anyPath, completion: done
                            )
                        }
                    }

                    it("THEN they should all call the URLConverter method with a nil baseURL and token") {
                        expect(urlConverter.urlCallCount).to(equal(3))
                        expect(urlConverter.urlArguments.count).to(equal(3))
                        urlConverter.urlArguments.forEach {
                            expect($0.baseURL).to(beNil())
                            expect($0.token).to(beNil())
                            expect($0.path).to(equal(anyPath))
                        }
                    }
                }

            }

            describe("GIVEN a session configuration with a baseURL and token") {
                let sessionBaseURL = "sessionBaseURL"
                let sessionToken = "sessionToken"
                beforeEach {
                    sessionReader.configurationResult = {
                        .init(token: sessionToken, baseURL: sessionBaseURL)
                    }
                }

                context("WHEN we call request, upload and download") {
                    beforeEach {
                        waitUntil { (done) in
                            self.requestUploadAndDownload(
                                with: sut, path: anyPath, completion: done
                            )
                        }
                    }

                    it("THEN they should all call the URLConverter method with the session baseURL and token") {
                        expect(urlConverter.urlCallCount).to(equal(3))
                        expect(urlConverter.urlArguments.count).to(equal(3))
                        urlConverter.urlArguments.forEach {
                            expect($0.baseURL).to(equal(sessionBaseURL))
                            expect($0.token).to(equal(sessionToken))
                            expect($0.path).to(equal(anyPath))
                        }
                    }
                }
            }
        }

        describe("GIVEN a sut configuration with a baseURL and token") {
            let baseURL = "baseURL"
            let token = "token"
            beforeEach {
                sut.set(baseURL: baseURL)
                sut.set(token: token)
            }

            describe("GIVEN a session configuration without a baseURL and token") {
                beforeEach {
                    sessionReader.configurationResult = { .init(token: nil, baseURL: nil) }
                }

                context("WHEN we call request, upload and download") {
                    beforeEach {
                        waitUntil { (done) in
                            self.requestUploadAndDownload(
                                with: sut, path: anyPath, completion: done
                            )
                        }
                    }

                    it("THEN they should all call the URLConverter method with the sut baseURL and token") {
                        expect(urlConverter.urlCallCount).to(equal(3))
                        expect(urlConverter.urlArguments.count).to(equal(3))
                        urlConverter.urlArguments.forEach {
                            expect($0.baseURL).to(equal(baseURL))
                            expect($0.token).to(equal(token))
                            expect($0.path).to(equal(anyPath))
                        }
                    }
                }
            }

            describe("GIVEN a session configuration with a baseURL and token") {
                let sessionBaseURL = "sessionBaseURL"
                let sessionToken = "sessionToken"
                beforeEach {
                    sessionReader.configurationResult = {
                        .init(token: sessionToken, baseURL: sessionBaseURL)
                    }
                }

                context("WHEN we call request, upload and download") {
                    beforeEach {
                        waitUntil { (done) in
                            self.requestUploadAndDownload(
                                with: sut, path: anyPath, completion: done
                            )
                        }
                    }

                    it("THEN they should all call the URLConverter method with the sut baseURL and token") {
                        expect(urlConverter.urlCallCount).to(equal(3))
                        expect(urlConverter.urlArguments.count).to(equal(3))
                        urlConverter.urlArguments.forEach {
                            expect($0.baseURL).to(equal(baseURL))
                            expect($0.token).to(equal(token))
                            expect($0.path).to(equal(anyPath))
                        }
                    }
                }
            }
        }
    }
}

private extension NetworkerURLComponentsBehavior {
    class func requestUploadAndDownload(with sut: Networker,
                                        path: String,
                                        completion: @escaping () -> Void) {
        let group = DispatchGroup()
        
        group.enter()
        sut.request(path: path) { (_) in
            group.leave()
        }

        group.enter()
        sut.upload(Data(), to: path, type: .post) { (_) in
            group.leave()
        }

        group.enter()
        sut.download(path: path, requestType: .get, fileHandler: nil) { (_) in
            group.leave()
        }

        group.notify(queue: .main) {
            completion()
        }
    }
}
