//
//  File.swift
//  
//
//  Created by RICHEZ Thibaut on 10/28/20.
//

import Foundation

extension Networker {
    private var sessionConfiguration: NetworkerSessionConfiguration? {
        self.sessionReader?.configuration
    }

    func makeURL(from path: String) throws -> URL {
        let baseURL = self.configuration.baseURL ?? self.sessionConfiguration?.baseURL
        let token = self.configuration.token ?? self.sessionConfiguration?.token

        let components = NetworkerURLComponents(
            baseURL: baseURL,
            token: token,
            path: path
        )
        return try self.urlConverter.url(from: components)
    }

    func makeURLRequest(for type: URLRequestType,
                        cachePolicy: NetworkerCachePolicy? = .partial,
                        with url: URL) -> URLRequest {
        var urlRequest = URLRequest(url: url, timeoutInterval: self.configuration.timeoutInterval)
        urlRequest.httpMethod = type.rawValue
        if let cachePolicy = cachePolicy {
            urlRequest.cachePolicy = .init(networkerPolicy: cachePolicy)
        }
        return urlRequest
    }

    func getHTTPResponse(from response: URLResponse?) throws -> HTTPURLResponse {
        guard let response = response else {
            throw NetworkerError.response(.empty)
        }

        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkerError.response(.invalid(response))
        }

        guard (200...299).contains(httpResponse.statusCode) else {
            throw NetworkerError.response(.statusCode(httpResponse))
        }

        let acceptableMimeTypes = self.acceptableMimeTypes.map { $0.rawValue }
        guard let mimeType = httpResponse.mimeType,
              acceptableMimeTypes.contains(mimeType) else {
            throw NetworkerError.response(
                .invalidMimeType(got: httpResponse.mimeType, allowed: acceptableMimeTypes)
            )
        }

        return httpResponse
    }

    func handleRemoteError(_ error: Error?) throws {
        if let error = error {
            throw NetworkerError.remote(NetworkerRemoteError(error))
        }
    }
}

extension Networker {


    private func makeBaseURL() throws -> URL {
        let baseURLConfiguration = self.configuration.baseURL ?? self.sessionConfiguration?.baseURL
        guard let baseURLRepresentation = baseURLConfiguration else {
            throw NetworkerError.path(.baseURLMissing)
        }

        guard let baseURL = URL(string: baseURLRepresentation) else {
            throw NetworkerError.path(.invalidBaseURL(baseURLRepresentation))
        }

        return baseURL
    }

    private func appendingToken(in url: URL) -> URL {
        let configurationToken = self.configuration.token ?? self.sessionConfiguration?.token
        guard let token = configurationToken else {
            return url
        }

        return url
            .appendingPathComponent(token, isDirectory: true)
    }
}