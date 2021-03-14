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

public protocol NetworkRequester {
    @discardableResult
    func request(
        _ urlConvertible: URLConvertible,
        method: HTTPMethod,
        requestModifiers: [NetworkerRequestModifier]?,
        responseValidators: [NetworkerResponseValidator]?,
        completion: @escaping (Result<NetworkRequesterResult, NetworkerError>) -> Void
    ) -> URLSessionTaskProtocol?

    @discardableResult
    func request(
        _ requestConvertible: URLRequestConvertible,
        responseValidators: [NetworkerResponseValidator]?,
        completion: @escaping (Result<NetworkRequesterResult, NetworkerError>) -> Void
    ) -> URLSessionTaskProtocol?
}

extension Networker: NetworkRequester {
    @discardableResult
    public func request(
        _ urlConvertible: URLConvertible,
        method: HTTPMethod = .get,
        requestModifiers: [NetworkerRequestModifier]? = nil,
        responseValidators: [NetworkerResponseValidator]? = nil,
        completion: @escaping (Result<NetworkRequesterResult, NetworkerError>) -> Void
    ) -> URLSessionTaskProtocol? {
        do {
            let url = try urlConvertible.asURL(relativeTo: self.configuration?.baseURL)
            let request = self.makeURLRequest(url, method: method, modifiers: requestModifiers)
            return self.request(request, responseValidators: responseValidators, completion: completion)
        } catch {
            self.dispatch(error, completion: completion)
            return nil
        }
    }
        
    @discardableResult
    public func request(
        _ requestConvertible: URLRequestConvertible,
        responseValidators: [NetworkerResponseValidator]? = nil,
        completion: @escaping (Result<NetworkRequesterResult, NetworkerError>) -> Void
    ) -> URLSessionTaskProtocol? {
        do {
            let request = try requestConvertible.asURLRequest()
            return self.request(request, responseValidators: responseValidators, completion: completion)
        } catch {
            self.dispatch(error, completion: completion)
            return nil
        }
    }
}

// MARK: - Helpers

private extension Networker {
    func request(
        _ request: URLRequest,
        responseValidators: [NetworkerResponseValidator]? = nil,
        completion: @escaping (Result<NetworkRequesterResult, NetworkerError>) -> Void
    ) -> URLSessionTaskProtocol {
        let operation = NetworkerOperation(
            request: request,
            executor: self.session.request(with:completion:)) { (data, response, error) in
            do {
                try self.handleRemoteError(error)
                let httpResponse = try self.getHTTPResponse(from: response, validators: responseValidators)
                let result = try self.getResult(with: data, response: httpResponse)
                self.dispatch(result, completion: completion)
            } catch  {
                self.dispatch(error, completion: completion)
            }
        }
        self.queues.operation.addOperation(operation)
        return operation.task
    }

    func getResult(with data: Data?,
                   response: HTTPURLResponse) throws -> NetworkRequesterResult {
        guard let data = data else { throw NetworkerError.response(.emptyData(response)) }
        
        return .init(data: data, statusCode: response.statusCode, headerFields: response.allHeaderFields)
    }
}
