//
//  NetworkConfigurableTests.swift.swift
//  
//
//  Created by RICHEZ Thibaut on 10/25/20.
//
import XCTest
import Quick
import Nimble
@testable import Networker

final class NetworkConfigurableTests: QuickSpec {
    override func spec() {
        describe("GIVEN a configuration with a baseURL URLSession mock and a NetworkerQueues mock") {
            let networkBaseURL = "https://testing.com/"
            let networkToken = "AZERTHGVCSAE&1234"
            var session: URLSessionMock!
            var queues: NetworkerQueuesMock!
            var sut: Networker!
            beforeEach {
                session = .init()
                let configuration = NetworkerConfiguration(baseURL: networkBaseURL, token: networkToken)
                queues = .init()
                sut = .init(
                    session: session,
                    configuration: configuration,
                    queues: queues
                )
            }

            context("WHEN we call setBaseURL with a new value") {
                let newBaseURL = "https://release.com/"
                assert(newBaseURL != networkBaseURL)
                beforeEach {
                    sut.set(baseURL: newBaseURL)
                }

                it("THEN it should change the value of the session configuration") {
                    expect(sut.configuration.baseURL).to(equal(newBaseURL))

                    expect(sut.configuration.token).to(equal(networkToken))

                    expect(queues.didCallAsyncCallback).to(beFalse())
                    expect(queues.didCallAddOperation).to(beFalse())
                    expect(queues.didCallCancelAllOperations).to(beFalse())
                }
            }

            context("WHEN we call setToken with a new value") {
                let newToken = "1234TFDHGFCVBJHG"
                assert(newToken != networkToken)
                beforeEach {
                    sut.set(token: newToken)
                }

                it("THEN it should change the value of the session configuration") {
                    expect(sut.configuration.token).to(equal(newToken))

                    expect(sut.configuration.baseURL).to(equal(networkBaseURL))

                    expect(queues.didCallAsyncCallback).to(beFalse())
                    expect(queues.didCallAddOperation).to(beFalse())
                    expect(queues.didCallCancelAllOperations).to(beFalse())
                }
            }
        }
    }
}
