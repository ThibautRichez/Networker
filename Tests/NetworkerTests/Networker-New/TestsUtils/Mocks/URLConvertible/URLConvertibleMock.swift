//
//  URLConvertibleMock.swift
//  
//
//  Created by RICHEZ Thibaut on 5/6/21.
//

import Foundation
@testable import Networker

final class URLConvertibleMock: URLConvertible {
    var asURLCallCount = 0
    var asURLArguments = [URLConvertible?]()
    var didCallAsURL: Bool {
        self.asURLCallCount > 0
    }
    var result: ((URLConvertible?) throws -> URL)

    init(result: (@escaping (URLConvertible?) throws -> URL)) {
        self.result = result
    }

    func asURL(relativeTo baseURL: URLConvertible?) throws -> URL {
        self.asURLCallCount += 1
        self.asURLArguments.append(baseURL)
        return try self.result(baseURL)
    }
}
