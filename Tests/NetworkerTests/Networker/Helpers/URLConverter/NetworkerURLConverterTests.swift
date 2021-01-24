//
//  NetworkerURLConverterTests.swift
//  
//
//  Created by RICHEZ Thibaut on 10/29/20.
//

import Foundation
import Quick
import Nimble
@testable import Networker

final class NetworkerURLConverterTests: QuickSpec {
    override func spec() {
        describe("GIVEN a sut") {
            var urlConcatener: URLStringConcatenerMock!
            var sut: NetworkerURLConverter!
            beforeEach {
                urlConcatener = .init()
                sut = .init(urlConcatener: urlConcatener)
                URLSession.shared.getTasks { (_) in
                    
                }
            }

            itBehavesLike(NetworkerURLConverterAbsolutePathBehavior.self) { sut }

            itBehavesLike(NetworkerURLConverterRelativePathBehavior.self) { sut }
        }
    }
}
