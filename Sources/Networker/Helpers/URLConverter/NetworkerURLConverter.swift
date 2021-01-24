//
//  NetworkerURLConverter.swift
//  
//
//  Created by RICHEZ Thibaut on 10/29/20.
//

import Foundation

public struct NetworkerURLComponents {
    public var baseURL: String?
    public var token: String?
    public var path: String

    public init(baseURL: String? = nil,
                token: String? = nil,
                path: String) {
        self.baseURL = baseURL
        self.token = token
        self.path = path
    }
}

public protocol URLConverter {
    func url(from components: NetworkerURLComponents) throws -> URL
}

public struct NetworkerURLConverter {
    var urlConcatener: URLStringConcatener

    public init(urlConcatener: URLStringConcatener = NetworkerURLStringConcatener()) {
        self.urlConcatener = urlConcatener
    }
}

// MARK: - URLConverter

extension NetworkerURLConverter: URLConverter {
    public func url(from components: NetworkerURLComponents) throws -> URL {
        if components.path.isAbsoluteURL {
            return try self.makeAbsoluteURL(from: components.path)
        }

        var baseURL = try self.makeBaseURL(from: components.baseURL)
        self.append(token: components.token, in: &baseURL)
        return try self.makeURL(with: baseURL.absoluteString, path: components.path)
    }
}

private extension NetworkerURLConverter {
    func makeAbsoluteURL(from path: String) throws -> URL {
        guard let absoluteURL = URL(string: path) else {
            throw NetworkerError.path(.invalidAbsolutePath(path))
        }

        return absoluteURL
    }

    func makeBaseURL(from path: String?) throws -> URL {
        guard let baseURLRepresentation = path else {
            throw NetworkerError.path(.baseURLMissing)
        }

        guard baseURLRepresentation.isAbsoluteURL,
              let baseURL = URL(string: baseURLRepresentation) else {
            throw NetworkerError.path(.invalidBaseURL(baseURLRepresentation))
        }

        return baseURL
    }

    func append(token: String?, in value: inout URL) {
        guard let token = token else { return }

        value.appendPathComponent(token, isDirectory: true)
    }

    func makeURL(with baseURL: String, path: String) throws -> URL {
        let urlRepresentation = self.urlConcatener.concat(baseURL, with: path)
        guard let url = URL(string: urlRepresentation) else {
            throw NetworkerError.path(.invalidRelativePath(path))
        }

        return url
    }
}
