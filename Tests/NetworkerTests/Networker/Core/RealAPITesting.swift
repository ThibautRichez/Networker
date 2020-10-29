//
//  RealAPITesting.swift
//  
//
//  Created by RICHEZ Thibaut on 10/29/20.
//

import Foundation
import Quick
import Nimble
@testable import Networker

final class RealAPITesting: QuickSpec {
    override func spec() {
        xdescribe("GIVEN a URLSession mock, a SessionConfigurationReader and a NetworkerQueues mock") {
            var sut: Networker!
            beforeEach {
                let configuration = NetworkerConfiguration(
                    baseURL: "https://api.nextradiotv.com/bfmbusiness-applications",
                    token: "e742eb6115fe627384f960c4aa3f9810"
                )
                sut = Networker(configuration: configuration)
            }

            context("WHEN i request getHome") {
                var requestResult: NetworkRequesterResult?
                var error: NetworkerError?
                beforeEach {
                    waitUntil(timeout: .seconds(5)) { (done) in
                        sut.request(path: "getPage?pagename=home") { (result) in
                            requestResult = try? result.get()
                            error = result.error
                            done()
                        }
                    }
                }

                it("THEN") {
                    expect(error).to(beNil())

                    let stringValue = String(
                        data: requestResult?.data ?? .init(),
                        encoding: .utf8
                    )
                    expect(stringValue).to(equal("Something"))
                }
            }
        }
    }
}
