//
//  URLConverter.swift
//  
//
//  Created by RICHEZ Thibaut on 10/29/20.
//

import Foundation

struct NetworkerURLComponents {
    var baseURL: String?
    var token: String?
    var path: String
}

protocol URLConverter {
    func url(from components: NetworkerURLComponents) throws -> URL
}

struct NetworkerURLConverter: URLConverter {
    func url(from components: NetworkerURLComponents) throws -> URL {
        if components.path.isAbsoluteURL {
            guard let absoluteURL = URL(string: components.path) else {
                throw NetworkerError.path(.invalidAbsolutePath(components.path))
            }
            return absoluteURL
        }

        guard let baseURLRepresentation = components.baseURL else {
            throw NetworkerError.path(.baseURLMissing)
        }

        guard var baseURL = URL(string: baseURLRepresentation) else {
            throw NetworkerError.path(.invalidBaseURL(baseURLRepresentation))
        }

        if let token = components.token {
            baseURL.appendPathComponent(token, isDirectory: true)
        }

        // not using appendingPathComponent because path may contain
        // non component information that will be formatted otherwise
        // (query items for exemple)
        // base-url.com getPage
        // base-url.com/ getPage
        // base-url.com /getPage
        // base-url.com/ /getPage
        // base-url.com /
        guard let url = URL(string: baseURL.absoluteString + components.path) else {
            throw NetworkerError.path(.invalidRelativePath(components.path))
        }

        return url
    }
}
