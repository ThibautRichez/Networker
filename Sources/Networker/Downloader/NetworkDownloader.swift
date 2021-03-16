//
//  NetworkDownloader.swift
//  
//
//  Created by RICHEZ Thibaut on 10/25/20.
//

import Foundation

public struct NetworkDownloaderResult {
    public var statusCode: Int
    public var headerFields: [AnyHashable : Any]

    public init(statusCode: Int, headerFields: [AnyHashable : Any]) {
        self.statusCode = statusCode
        self.headerFields = headerFields
    }
}

public protocol NetworkDownloader {
    @discardableResult
    func download(
        _ url: URLConvertible,
        method: HTTPMethod,
        fileHandler: @escaping (URL) -> Void,
        requestModifiers modifiers: [NetworkerRequestModifier]?,
        responseValidators validators: [NetworkerResponseValidator]?,
        completion: @escaping (Result<NetworkDownloaderResult, NetworkerError>) -> Void
    ) -> NetworkerOperationProtocol?

    @discardableResult
    func download(
        _ request: URLRequestConvertible,
        fileHandler: @escaping (URL) -> Void,
        responseValidators validators: [NetworkerResponseValidator]?,
        completion: @escaping (Result<NetworkDownloaderResult, NetworkerError>
        ) -> Void) -> NetworkerOperationProtocol?
}

extension Networker: NetworkDownloader {
    @discardableResult
    public func download(
        _ url: URLConvertible,
        method: HTTPMethod = .get,
        fileHandler: @escaping (URL) -> Void,
        requestModifiers modifiers: [NetworkerRequestModifier]? = nil,
        responseValidators validators: [NetworkerResponseValidator]? = nil,
        completion: @escaping (Result<NetworkDownloaderResult, NetworkerError>) -> Void
    ) -> NetworkerOperationProtocol? {
        do {
            let request = try self.makeURLRequest(url, method: method, modifiers: modifiers)
            return self.download(urlRequest: request, fileHandler: fileHandler, validators: validators, completion: completion)
        } catch {
            self.dispatch(error, completion: completion)
            return nil
        }
    }

    @discardableResult
    public func download(
        _ request: URLRequestConvertible,
        fileHandler: @escaping (URL) -> Void,
        responseValidators validators: [NetworkerResponseValidator]? = nil,
        completion: @escaping (Result<NetworkDownloaderResult, NetworkerError>) -> Void
    ) -> NetworkerOperationProtocol? {
        do {
            let request = try request.asURLRequest()
            return self.download(urlRequest: request, fileHandler: fileHandler, validators: validators, completion: completion)
        } catch {
            self.dispatch(error, completion: completion)
            return nil
        }
    }
}

private extension Networker {
    func download(
        urlRequest: URLRequest,
        fileHandler: @escaping (URL) -> Void,
        validators: [NetworkerResponseValidator]? = nil,
        completion: @escaping (Result<NetworkDownloaderResult, NetworkerError>) -> Void
    ) -> NetworkerOperationProtocol? {
        let operation = NetworkerOperation(
            request: urlRequest,
            executor: self.session.download(with:completion:)) { (fileURL, response, error) in
            do {
                let httpResponse = try self.getHTTPResponse(error: error, urlResponse: response, validators: validators)
                try self.executeFilehandler(fileURL: fileURL, fileHandler: fileHandler)
                let result = self.getResult(response: httpResponse)
                self.dispatch(result, completion: completion)
            } catch {
                self.dispatch(error, completion: completion)
            }
        }

        self.queues.operation.addOperation(operation)
        return operation
    }

    func executeFilehandler(fileURL: URL?, fileHandler: ((URL) -> Void)) throws {
        guard let url = fileURL else {
            throw NetworkerError.download(.fileURLMissing)
        }

        fileHandler(url)
    }

    func getResult(response: HTTPURLResponse) -> NetworkDownloaderResult {
        return .init(
            statusCode: response.statusCode,
            headerFields: response.allHeaderFields
        )
    }
}
