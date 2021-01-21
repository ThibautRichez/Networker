//
//  Networker+Requester.swift
//  
//
//  Created by RICHEZ Thibaut on 10/25/20.
//

import Foundation

struct NetworkRequesterResult {
    var data: Data
    var statusCode: Int
    var headerFields: [AnyHashable : Any]
}

protocol NetworkRequester: NetworkConfigurable {
    @discardableResult
    func request(path: String,
                 cachePolicy: NetworkerCachePolicy?,
                 completion: @escaping (Result<NetworkRequesterResult, NetworkerError>) -> Void) -> URLSessionTaskProtocol?
    @discardableResult
    func request(url: URL,
                 cachePolicy: NetworkerCachePolicy?,
                 completion: @escaping (Result<NetworkRequesterResult, NetworkerError>) -> Void) -> URLSessionTaskProtocol
    @discardableResult
    func request(urlRequest: URLRequest,
                 completion: @escaping (Result<NetworkRequesterResult, NetworkerError>) -> Void) -> URLSessionTaskProtocol
}

extension Networker: NetworkRequester {
    @discardableResult
    func request(path: String,
                 cachePolicy: NetworkerCachePolicy? = .partial,
                 completion: @escaping (Result<NetworkRequesterResult, NetworkerError>) -> Void) -> URLSessionTaskProtocol? {
        do {
            let requestURL = try self.makeURL(from: path)
            return self.request(
                url: requestURL,
                cachePolicy: cachePolicy,
                completion: completion
            )
        } catch {
            self.dispatch(error, completion: completion)
            return nil
        }
    }

    @discardableResult
    func request(url: URL,
                 cachePolicy: NetworkerCachePolicy? = .partial,
                 completion: @escaping (Result<NetworkRequesterResult, NetworkerError>) -> Void) -> URLSessionTaskProtocol {
        let request = self.makeURLRequest(for: .get, cachePolicy: cachePolicy, with: url)
        return self.request(urlRequest: request, completion: completion)
    }

    @discardableResult
    func request(urlRequest: URLRequest,
                 completion: @escaping (Result<NetworkRequesterResult, NetworkerError>) -> Void) -> URLSessionTaskProtocol {
        let operation = NetworkerOperation(
            request: urlRequest,
            executor: self.session.request(with:completion:)) { (data, response, error) in
            do {
                try self.handleRemoteError(error)
                let httpResponse = try self.getHTTPResponse(from: response)
                let result = try self.getResult(with: data, response: httpResponse)
                self.dispatch(result, completion: completion)
            } catch  {
                self.dispatch(error, completion: completion)
            }
        }

        self.queues.addOperation(operation)
        return operation.task
    }
}

// MARK: - Helpers

private extension Networker {
    func getResult(with data: Data?, response: HTTPURLResponse) throws -> NetworkRequesterResult {
        guard let data = data else { throw NetworkerError.response(.empty) }

        return .init(
            data: data,
            statusCode: response.statusCode,
            headerFields: response.allHeaderFields
        )
    }
}
