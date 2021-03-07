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

    func makeURLRequest(_ url: URL,
                        method: HTTPMethod,
                        modifiers: [NetworkerRequestModifier]? = nil) -> URLRequest {
        let timeoutInterval = self.configuration.timeoutInterval
        var urlRequest = URLRequest(url: url, timeoutInterval: timeoutInterval)
        urlRequest.httpMethod = method.rawValue
        urlRequest.allHTTPHeaderFields = self.sessionConfiguration?.headers
        if let modifiers = modifiers {
            urlRequest.apply(modifiers: modifiers)
        }
        return urlRequest
    }

    func getHTTPResponse(from response: URLResponse?,
                         validators: [NetworkerResponseValidator]? = nil) throws -> HTTPURLResponse {
        guard let response = response else {
            throw NetworkerError.response(.empty)
        }

        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkerError.response(.invalid(response))
        }

        do {
            try httpResponse.validate(using: validators.appendingDefaultValidators())
            return httpResponse
        } catch let error as NetworkerResponseValidatorError {
            throw NetworkerError.response(.validator(error))
        } catch {
            throw NetworkerError.response(.validator(.custom(error, httpResponse)))
        }
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
}
