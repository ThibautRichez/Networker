//
//  URLConvertible+URL.swift
//  
//
//  Created by RICHEZ Thibaut on 5/6/21.
//

import Foundation

extension URL: URLConvertible {
    public func asURL(relativeTo baseURL: URLConvertible? = nil) throws -> URL {
        if let baseURL = baseURL, let components = URLComponents(url: self, resolvingAgainstBaseURL: true) {
            return try components.asURL(relativeTo: baseURL)
        }

        return self
    }
}
