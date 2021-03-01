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
}

public enum NetworkUploaderType {
    case post
    case put
}

extension NetworkUploaderType {
    var requestType: URLRequestType {
        switch self {
        case .post:
            return .post
        case .put:
            return .put
        }
    }
}

public protocol NetworkUploader: NetworkConfigurable {
    @discardableResult
    func upload(
        path: String,
        type: NetworkUploaderType,
        data: Data?,
        options: [NetworkerOption]?,
        completion: @escaping (Result<NetworkUploaderResult, NetworkerError>) -> Void) -> URLSessionTaskProtocol?

    @discardableResult
    func upload(
        url: URL,
        type: NetworkUploaderType,
        data: Data?,
        options: [NetworkerOption]?,
        completion: @escaping (Result<NetworkUploaderResult, NetworkerError>) -> Void) -> URLSessionTaskProtocol?

    @discardableResult
    func upload(
        urlRequest: URLRequest,
        data: Data?,
        completion: @escaping (Result<NetworkUploaderResult, NetworkerError>) -> Void) -> URLSessionTaskProtocol?
}

extension Networker: NetworkUploader {
    @discardableResult
    public func upload(
        path: String,
        type: NetworkUploaderType,
        data: Data?,
        options: [NetworkerOption]? = nil,
        completion: @escaping (Result<NetworkUploaderResult, NetworkerError>) -> Void) -> URLSessionTaskProtocol? {
        do {
            let uploadURL = try self.makeURL(from: path)
            return self.upload(
                url: uploadURL,
                type: type,
                data: data,
                options: options,
                completion: completion
            )
        } catch {
            self.dispatch(error, completion: completion)
            return nil
        }
    }

    @discardableResult
    public func upload(
        url: URL,
        type: NetworkUploaderType,
        data: Data?,
        options: [NetworkerOption]? = nil,
        completion: @escaping (Result<NetworkUploaderResult, NetworkerError>) -> Void) -> URLSessionTaskProtocol? {
        let requestType = type.requestType
        let request = self.makeURLRequest(for: requestType, options: options, with: url)
        return self.upload(urlRequest: request, data: data, completion: completion)
    }

    @discardableResult
    public func upload(
        urlRequest: URLRequest,
        data: Data?,
        completion: @escaping (Result<NetworkUploaderResult, NetworkerError>) -> Void) -> URLSessionTaskProtocol? {
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

extension Networker {
    private func getResult(with data: Data?, response: HTTPURLResponse) -> NetworkUploaderResult {
        return .init(
            data: data,
            statusCode: response.statusCode,
            headerFields: response.allHeaderFields
        )
    }
}
