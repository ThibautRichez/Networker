//
//  URLConvertible+String.swift
//  
//
//  Created by RICHEZ Thibaut on 5/6/21.
//

import Foundation

extension String: URLConvertible {
    public func asURL(relativeTo baseURL: URLConvertible? = nil) throws -> URL {
        if let baseURL = baseURL,
           let components = URLComponents(url: try self.asURL(), resolvingAgainstBaseURL: true) {
            return try components.asURL(relativeTo: baseURL)
        } else if let url = URL(string: self) {
            return url
        }

        throw NetworkerError.invalidURL(self)
    }
}
