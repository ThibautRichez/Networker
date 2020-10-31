//
//  URLConverterMock.swift
//  
//
//  Created by RICHEZ Thibaut on 10/31/20.
//

import Foundation
@testable import Networker

final class URLConverterMock: URLConverter {
    var urlCallCount = 0
    var urlArguments = [NetworkerURLComponents]()
    var urlResult: (() throws -> URL)?
    var didCallURL: Bool {
        self.urlCallCount > 0
    }

    func url(from components: NetworkerURLComponents) throws -> URL {
        self.urlCallCount += 1
        self.urlArguments.append(components)
        guard let result = urlResult else {
            throw NSError(domain: "URL result should be set before called", code: 0, userInfo: nil)
        }

        return try result()
    }
}
