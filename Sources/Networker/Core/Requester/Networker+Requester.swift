//
//  Networker+Requester.swift
//  
//
//  Created by RICHEZ Thibaut on 10/25/20.
//

import Foundation

public struct NetworkRequesterResult {
    public var data: Data
    public var statusCode: Int
    public var headerFields: [AnyHashable : Any]
    
    public init(data: Data, statusCode: Int, headerFields: [AnyHashable : Any]) {
        self.data = data
        self.statusCode = statusCode
        self.headerFields = headerFields
    }
}

public protocol NetworkRequester: NetworkConfigurable {
    @discardableResult
    func request(
        _ path: String,
        method: HTTPMethod,
        options: [NetworkerOption]?,
        completion: @escaping (Result<NetworkRequesterResult, NetworkerError>) -> Void
    ) -> URLSessionTaskProtocol?
    
    @discardableResult
    func request(
        _ url: URL,
        method: HTTPMethod,
        options: [NetworkerOption]?,
        completion: @escaping (Result<NetworkRequesterResult, NetworkerError>) -> Void
    ) -> URLSessionTaskProtocol
    
    @discardableResult
    func request(
        _ urlRequest: URLRequest,
        completion: @escaping (Result<NetworkRequesterResult, NetworkerError>) -> Void
    ) -> URLSessionTaskProtocol
}

extension Networker: NetworkRequester {
    @discardableResult
    public func request(
        _ path: String,
        method: HTTPMethod = .get,
        options: [NetworkerOption]? = nil,
        completion: @escaping (Result<NetworkRequesterResult, NetworkerError>) -> Void
    ) -> URLSessionTaskProtocol? {
        do {
            let requestURL = try self.makeURL(from: path)
            return self.request(
                requestURL, method: method,
                options: options, completion: completion
            )
        } catch {
            self.dispatch(error, completion: completion)
            return nil
        }
    }
    
    @discardableResult
    public func request(
        _ url: URL,
        method: HTTPMethod = .get,
        options: [NetworkerOption]? = nil,
        completion: @escaping (Result<NetworkRequesterResult, NetworkerError>) -> Void
    ) -> URLSessionTaskProtocol {
        let request = self.makeURLRequest(with: method, options: options, with: url)
        return self.request(request, completion: completion)
    }
    
    @discardableResult
    public func request(
        _ urlRequest: URLRequest,
        completion: @escaping (Result<NetworkRequesterResult, NetworkerError>) -> Void
    ) -> URLSessionTaskProtocol {
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
    func getResult(with data: Data?,
                   response: HTTPURLResponse) throws -> NetworkRequesterResult {
        guard let data = data else { throw NetworkerError.response(.empty) }
        
        return .init(data: data, statusCode: response.statusCode, headerFields: response.allHeaderFields)
    }
}
