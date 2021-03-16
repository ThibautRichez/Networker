//
//  NetworkUploader.swift
//  
//
//  Created by RICHEZ Thibaut on 10/25/20.
//

import Foundation

public struct NetworkUploaderResult {
    public var data: Data?
    public var statusCode: Int
    public var headerFields: [AnyHashable : Any]
    
    public init(data: Data? = nil, statusCode: Int, headerFields: [AnyHashable : Any]) {
        self.data = data
        self.statusCode = statusCode
        self.headerFields = headerFields
    }
}

public protocol NetworkUploader {
    @discardableResult
    func upload(
        _ data: Data,
        to url: URLConvertible,
        method: HTTPMethod,
        requestModifiers modifiers: [NetworkerRequestModifier]?,
        responseValidators validators: [NetworkerResponseValidator]?,
        completion: @escaping (Result<NetworkUploaderResult, NetworkerError>) -> Void
    ) -> NetworkerOperationProtocol?

    @discardableResult
    func upload(
        _ data: Data,
        with request: URLRequestConvertible,
        responseValidators validators: [NetworkerResponseValidator]?,
        completion: @escaping (Result<NetworkUploaderResult, NetworkerError>) -> Void
    ) -> NetworkerOperationProtocol?
}

extension Networker: NetworkUploader {
    @discardableResult
    public func upload(
        _ data: Data,
        to url: URLConvertible,
        method: HTTPMethod = .post,
        requestModifiers modifiers: [NetworkerRequestModifier]? = nil,
        responseValidators validators: [NetworkerResponseValidator]? = nil,
        completion: @escaping (Result<NetworkUploaderResult, NetworkerError>) -> Void
    ) -> NetworkerOperationProtocol? {
        do {
            let request = try self.makeURLRequest(url, method: method, modifiers: modifiers)
            return self.upload(data, urlRequest: request, validators: validators, completion: completion)
        } catch {
            self.dispatch(error, completion: completion)
            return nil
        }
    }

    @discardableResult
    public func upload(
        _ data: Data,
        with request: URLRequestConvertible,
        responseValidators validators: [NetworkerResponseValidator]? = nil,
        completion: @escaping (Result<NetworkUploaderResult, NetworkerError>) -> Void
    ) -> NetworkerOperationProtocol? {
        do {
            let request = try request.asURLRequest()
            return self.upload(data, urlRequest: request, validators: validators, completion: completion)
        } catch {
            self.dispatch(error, completion: completion)
            return nil
        }
    }
}

// MARK: - Helpers

private extension Networker {
    func upload(
        _ data: Data,
        urlRequest: URLRequest,
        validators: [NetworkerResponseValidator]? = nil,
        completion: @escaping (Result<NetworkUploaderResult, NetworkerError>) -> Void
    ) -> NetworkerOperationProtocol? {
        let operation = NetworkerOperation(
            request: urlRequest,
            data: data,
            executor: self.session.upload(with:from:completion:)) { (data, response, error) in
            do {
                let httpResponse = try self.getHTTPResponse(error: error, urlResponse: response, validators: validators)
                let result = self.getResult(with: data, response: httpResponse)
                self.dispatch(result, completion: completion)
            } catch {
                self.dispatch(error, completion: completion)
            }
        }

        self.queues.operation.addOperation(operation)
        return operation
    }

    func getResult(with data: Data?, response: HTTPURLResponse) -> NetworkUploaderResult {
        return .init(data: data, statusCode: response.statusCode, headerFields: response.allHeaderFields)
    }
}
