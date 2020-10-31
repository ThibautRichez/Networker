//
//  URLStringConcatenerMock.swift
//  
//
//  Created by RICHEZ Thibaut on 10/31/20.
//

import Foundation
@testable import Networker

final class URLStringConcatenerMock: URLStringConcatener {
    var concatCallCount = 0
    var concatArguments = [(value: String, otherString: String)]()
    var concatResult: (() -> String)?
    var didCallConcat: Bool {
        self.concatCallCount > 0
    }

    func concat(_ value: String, with otherString: String) -> String {
        self.concatCallCount += 1
        self.concatArguments.append((value, otherString))
        return self.concatResult?() ?? ""
    }
}
