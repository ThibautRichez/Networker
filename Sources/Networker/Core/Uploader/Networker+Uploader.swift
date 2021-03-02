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

public protocol NetworkUploader: NetworkConfigurable {
    @discardableResult
    func upload(
        _ data: Data,
        to path: String,
        method: HTTPMethod,
        options: [NetworkerOption]?,
        completion: @escaping (Result<NetworkUploaderResult, NetworkerError>) -> Void
    ) -> URLSessionTaskProtocol?
    
    @discardableResult
    func upload(
        _ data: Data,
        to url: URL,
        method: HTTPMethod,
        options: [NetworkerOption]?,
        completion: @escaping (Result<NetworkUploaderResult, NetworkerError>) -> Void
    ) -> URLSessionTaskProtocol?
    
    @discardableResult
    func upload(
        _ data: Data,
        with urlRequest: URLRequest,
        completion: @escaping (Result<NetworkUploaderResult, NetworkerError>) -> Void
    ) -> URLSessionTaskProtocol?
}

extension Networker: NetworkUploader {
    @discardableResult
    public func upload(
        _ data: Data,
        to path: String,
        method: HTTPMethod = .post,
        options: [NetworkerOption]? = nil,
        completion: @escaping (Result<NetworkUploaderResult, NetworkerError>) -> Void
    ) -> URLSessionTaskProtocol? {
        do {
            let uploadURL = try self.makeURL(from: path)
            return self.upload(data, to: uploadURL, method: method, options: options, completion: completion)
        } catch {
            self.dispatch(error, completion: completion)
            return nil
        }
    }
    
    @discardableResult
    public func upload(
        _ data: Data,
        to url: URL,
        method: HTTPMethod = .post,
        options: [NetworkerOption]? = nil,
        completion: @escaping (Result<NetworkUploaderResult, NetworkerError>) -> Void
    ) -> URLSessionTaskProtocol? {
        let request = self.makeURLRequest(with: method, options: options, with: url)
        return self.upload(data, with: request, completion: completion)
    }
    
    @discardableResult
    public func upload(
        _ data: Data,
        with urlRequest: URLRequest,
        completion: @escaping (Result<NetworkUploaderResult, NetworkerError>) -> Void
    ) -> URLSessionTaskProtocol? {
        let operation = NetworkerOperation(
            request: urlRequest,
            data: data,
            executor: self.session.upload(with:from:completion:)) { (data, response, error) in
            do {
                try self.handleRemoteError(error)
                let httpResponse = try self.getHTTPResponse(from: response)
                let result = self.getResult(with: data, response: httpResponse)
                self.dispatch(result, completion: completion)
            } catch {
                self.dispatch(error, completion: completion)
            }
        }
        
        self.queues.addOperation(operation)
        return operation.task
    }
}

// MARK: - Helpers

private extension Networker {
    func getResult(with data: Data?, response: HTTPURLResponse) -> NetworkUploaderResult {
        return .init(data: data, statusCode: response.statusCode, headerFields: response.allHeaderFields)
    }
}
