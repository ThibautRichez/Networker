//
//  NetworkUploaderTests.swift
//  
//
//  Created by RICHEZ Thibaut on 10/26/20.
//

import Foundation
import XCTest
import Quick
import Nimble
@testable import Networker

final class NetworkUploaderTests: QuickSpec {
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
        }
    }
}
