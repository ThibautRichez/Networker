//
//  Networker+Uploader.swift
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
        to urlConvertible: URLConvertible,
        method: HTTPMethod,
        requestModifiers: [NetworkerRequestModifier]?,
        responseValidators: [NetworkerResponseValidator]?,
        completion: @escaping (Result<NetworkUploaderResult, NetworkerError>) -> Void
    ) -> URLSessionTaskProtocol?

    @discardableResult
    func upload(
        _ data: Data,
        with requestConvertible: URLRequestConvertible,
        responseValidators: [NetworkerResponseValidator]?,
        completion: @escaping (Result<NetworkUploaderResult, NetworkerError>) -> Void
    ) -> URLSessionTaskProtocol?
}

extension Networker: NetworkUploader {
    @discardableResult
    public func upload(
        _ data: Data,
        to urlConvertible: URLConvertible,
        method: HTTPMethod = .post,
        requestModifiers: [NetworkerRequestModifier]? = nil,
        responseValidators: [NetworkerResponseValidator]? = nil,
        completion: @escaping (Result<NetworkUploaderResult, NetworkerError>) -> Void
    ) -> URLSessionTaskProtocol? {
        do {
            let url = try urlConvertible.asURL(relativeTo: self.configuration?.baseURL)
            let request = self.makeURLRequest(url, method: method, modifiers: requestModifiers)
            return self.upload(data, with: request, responseValidators: responseValidators, completion: completion)
        } catch {
            self.dispatch(error, completion: completion)
            return nil
        }
    }

    @discardableResult
    public func upload(
        _ data: Data,
        with requestConvertible: URLRequestConvertible,
        responseValidators: [NetworkerResponseValidator]? = nil,
        completion: @escaping (Result<NetworkUploaderResult, NetworkerError>) -> Void
    ) -> URLSessionTaskProtocol? {
        do {
            let request = try requestConvertible.asURLRequest()
            return self.upload(data, with: request, completion: completion)
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
        with request: URLRequest,
        responseValidators: [NetworkerResponseValidator]? = nil,
        completion: @escaping (Result<NetworkUploaderResult, NetworkerError>) -> Void
    ) -> URLSessionTaskProtocol? {
        let operation = NetworkerOperation(
            request: request,
            data: data,
            executor: self.session.upload(with:from:completion:)) { (data, response, error) in
            do {
                try self.handleRemoteError(error)
                let httpResponse = try self.getHTTPResponse(from: response, validators: responseValidators)
                let result = self.getResult(with: data, response: httpResponse)
                self.dispatch(result, completion: completion)
            } catch {
                self.dispatch(error, completion: completion)
            }
        }

        self.queues.operation.addOperation(operation)
        return operation.task
    }

    func getResult(with data: Data?, response: HTTPURLResponse) -> NetworkUploaderResult {
        return .init(data: data, statusCode: response.statusCode, headerFields: response.allHeaderFields)
    }
}
