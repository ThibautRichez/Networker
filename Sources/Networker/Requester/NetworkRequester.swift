//
//  NetworkRequester.swift
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
        _ url: URLConvertible,
        method: HTTPMethod,
        requestModifiers modifiers: [NetworkerRequestModifier]?,
        responseValidators validators: [NetworkerResponseValidator]?,
        completion: @escaping (Result<NetworkRequesterResult, NetworkerError>) -> Void
    ) -> NetworkerOperationProtocol?

    @discardableResult
    func request(
        _ request: URLRequestConvertible,
        responseValidators validators: [NetworkerResponseValidator]?,
        completion: @escaping (Result<NetworkRequesterResult, NetworkerError>) -> Void
    ) -> NetworkerOperationProtocol?
}

extension Networker: NetworkRequester {
    @discardableResult
    public func request(
        _ url: URLConvertible,
        method: HTTPMethod = .get,
        requestModifiers modifiers: [NetworkerRequestModifier]? = nil,
        responseValidators validators: [NetworkerResponseValidator]? = nil,
        completion: @escaping (Result<NetworkRequesterResult, NetworkerError>) -> Void
    ) -> NetworkerOperationProtocol? {
        do {
            let request = try self.makeURLRequest(url, method: method, modifiers: modifiers)
            return self.request(urlRequest: request, validators: validators, completion: completion)
        } catch {
            self.dispatch(error, completion: completion)
            return nil
        }
    }

    @discardableResult
    public func request(
        _ request: URLRequestConvertible,
        responseValidators validators: [NetworkerResponseValidator]? = nil,
        completion: @escaping (Result<NetworkRequesterResult, NetworkerError>) -> Void
    ) -> NetworkerOperationProtocol? {
        do {
            let request = try request.asURLRequest()
            return self.request(urlRequest: request, validators: validators, completion: completion)
        } catch {
            self.dispatch(error, completion: completion)
            return nil
        }
    }
}

// MARK: - Helpers

private extension Networker {
    func request(
        urlRequest: URLRequest,
        validators: [NetworkerResponseValidator]? = nil,
        completion: @escaping (Result<NetworkRequesterResult, NetworkerError>) -> Void
    ) -> NetworkerOperationProtocol {
        let operation = NetworkerOperation(
            request: urlRequest,
            executor: self.session.request(with:completion:)) { (data, response, error) in
            do {
                let httpResponse = try self.getHTTPResponse(error: error, urlResponse: response, validators: validators)
                let result = try self.getResult(with: data, response: httpResponse)
                self.dispatch(result, completion: completion)
            } catch  {
                self.dispatch(error, completion: completion)
            }
        }

        self.queues.operation.addOperation(operation)
        return operation
    }

    func getResult(with data: Data?, response: HTTPURLResponse) throws -> NetworkRequesterResult {
        guard let data = data else {
            throw NetworkerError.response(.emptyData(response))
        }
        
        return .init(data: data, statusCode: response.statusCode, headerFields: response.allHeaderFields)
    }
}
