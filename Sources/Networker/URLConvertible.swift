//
//  URLConvertible.swift
//  
//
//  Created by RICHEZ Thibaut on 3/14/21.
//

import Foundation

// TODO: Add DOC
public protocol URLConvertible {
    func asURL(relativeTo baseURL: URLConvertible?) throws -> URL
}

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

extension URL: URLConvertible {
    public func asURL(relativeTo baseURL: URLConvertible? = nil) throws -> URL {
        if let baseURL = baseURL, let components = URLComponents(url: self, resolvingAgainstBaseURL: true) {
            return try components.asURL(relativeTo: baseURL)
        }

        return self
    }
}

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
