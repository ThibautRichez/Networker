//
//  File.swift
//  
//
//  Created by RICHEZ Thibaut on 10/28/20.
//

import Foundation

extension Networker {
    func makeURL(from path: String) throws -> URL {
        let baseURL = self.configuration.baseURL ?? self.sessionConfiguration?.baseURL
        let token = self.configuration.token ?? self.sessionConfiguration?.token

        let components = NetworkerURLComponents(baseURL: baseURL, token: token, path: path)
        return try self.urlConverter.url(from: components)
    }

    func makeURLRequest(for type: URLRequestType,
                        options: [NetworkerOption]? = nil,
                        with url: URL) -> URLRequest {
        let timeoutInterval = self.configuration.timeoutInterval
        var urlRequest = URLRequest(url: url, timeoutInterval: timeoutInterval)
        urlRequest.httpMethod = type.rawValue
        self.set(headers: self.sessionConfiguration?.headers, in: &urlRequest)
        self.handle(options: options, for: &urlRequest)
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

        let acceptableMimeTypes = self.acceptableMimeTypes.map(\.rawValue)
        guard let mimeType = httpResponse.mimeType,
              acceptableMimeTypes.contains(mimeType) else {
            throw NetworkerError.response(
                .invalidMimeType(got: httpResponse.mimeType, allowed: acceptableMimeTypes)
            )
        }

        return httpResponse
    }

    func handleRemoteError(_ error: Error?) throws {
        guard let error = error else { return }

        throw NetworkerError.remote(NetworkerRemoteError(error))
    }
}

private extension Networker {
    private var sessionConfiguration: NetworkerSessionConfiguration? {
        self.sessionReader?.configuration
    }

    // MARK: - Options

    func handle(options: [NetworkerOption]?, for request: inout URLRequest) {
        options?.forEach { option in
            switch option {
            case .cachePolicy(let policy):
                request.cachePolicy = .init(networkerPolicy: policy)
            case .headers(let headers):
                self.set(headers: headers, in: &request)
            case .serviceType(let type):
                request.networkServiceType = type
            case .authorizations(let authorizations):
                self.set(authorizations: authorizations, in: &request)
            }
        }
    }

    func set(headers: [String: String]?, in request: inout URLRequest) {
        headers?.forEach { key, value in
            request.setValue(value, forHTTPHeaderField: key)
        }
    }

    func set(authorizations: NetworkerAuthorizations, in request: inout URLRequest) {
        request.allowsCellularAccess = authorizations.contains(.cellularAccess)
        request.httpShouldHandleCookies = authorizations.contains(.cookies)

        if #available(iOS 13.0, *) {
            request.allowsExpensiveNetworkAccess = authorizations.contains(.expensiveNetworkAccess)
            request.allowsConstrainedNetworkAccess = authorizations.contains(.constrainedNetworkAccess)
        }
    }
}
