//
//  URLConvertible.swift
//  
//
//  Created by RICHEZ Thibaut on 3/14/21.
//

import Foundation

// TODO: Add DOC
public protocol URLConvertible {
    func asURL(relativeTo relativeURL: URLConvertible?) throws -> URL
}

extension String: URLConvertible {
    public func asURL(relativeTo relativeURL: URLConvertible? = nil) throws -> URL {
        if let relativeComponents = URLComponents(url: try relativeURL?.asURL(relativeTo: nil)),
           let components = URLComponents(url: URL(string: self))  {
            return try components.asURL(relativeTo: relativeComponents)
        } else if let url = URL(string: self) {
            return url
        } else {
            throw NetworkerError.invalidURL(self)
        }
    }
}

extension URL: URLConvertible {
    public func asURL(relativeTo relativeURL: URLConvertible? = nil) throws -> URL {
        if let relativeComponents = URLComponents(url: try relativeURL?.asURL(relativeTo: nil)),
           let components = URLComponents(url: self) {
            return try components.asURL(relativeTo: relativeComponents)
        } else {
            return self
        }
    }
}

extension URLComponents: URLConvertible {
    init?(url: URL?, resolvingAgainstBaseURL resolve: Bool = false) {
        guard let url = url else { return nil }

        self.init(url: url, resolvingAgainstBaseURL: resolve)
    }

    public func asURL(relativeTo relativeURL: URLConvertible? = nil) throws -> URL {
        if let relativeURL = try relativeURL?.asURL(relativeTo: nil),
           let url = self.url(relativeTo: relativeURL) {
            return url
        } else if let url = self.url {
            return url
        } else {
            throw NetworkerError.invalidURL(self)
        }
    }
}
