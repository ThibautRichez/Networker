//
//  File.swift
//  
//
//  Created by RICHEZ Thibaut on 5/6/21.
//

import Foundation

extension URLComponents: URLConvertible {
    public func asURL(relativeTo baseURL: URLConvertible? = nil) throws -> URL {
        if let baseURL = try baseURL?.asURL(relativeTo: nil),
           let url = self.url(relativeTo: baseURL) {
            return url
        } else if let url = self.url {
            return url
        }

        throw NetworkerError.invalidURL(self)
    }
}
