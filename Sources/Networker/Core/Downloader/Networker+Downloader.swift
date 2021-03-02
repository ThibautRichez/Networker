//
//  Networker+Downloader.swift
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

public protocol NetworkDownloader: NetworkConfigurable {
    @discardableResult
    func download(
        _ path: String,
        method: HTTPMethod,
        requestModifiers: [NetworkerRequestModifier]?,
        fileHandler: ((URL) -> Void)?,
        completion: @escaping (Result<NetworkDownloaderResult, NetworkerError>) -> Void
    ) -> URLSessionTaskProtocol?

    @discardableResult
    func download(
        _ url: URL,
        method: HTTPMethod,
        requestModifiers: [NetworkerRequestModifier]?,
        fileHandler: ((URL) -> Void)?,
        completion: @escaping (Result<NetworkDownloaderResult, NetworkerError>) -> Void
    ) -> URLSessionTaskProtocol?

    @discardableResult
    func download(
        _ urlRequest: URLRequest,
        fileHandler: ((URL) -> Void)?,
        completion: @escaping (Result<NetworkDownloaderResult, NetworkerError>
        ) -> Void) -> URLSessionTaskProtocol?
}

extension Networker: NetworkDownloader {
    @discardableResult
    public func download(
        _ path: String,
        method: HTTPMethod = .get,
        requestModifiers: [NetworkerRequestModifier]? = nil,
        fileHandler: ((URL) -> Void)?,
        completion: @escaping (Result<NetworkDownloaderResult, NetworkerError>) -> Void
    ) -> URLSessionTaskProtocol? {
        do {
            let uploadURL = try self.makeURL(from: path)
            return self.download(
                uploadURL, method: method, requestModifiers: requestModifiers,
                fileHandler: fileHandler, completion: completion
            )
        } catch {
            self.dispatch(error, completion: completion)
            return nil
        }
    }

    @discardableResult
    public func download(
        _ url: URL,
        method: HTTPMethod = .get,
        requestModifiers: [NetworkerRequestModifier]? = nil,
        fileHandler: ((URL) -> Void)?,
        completion: @escaping (Result<NetworkDownloaderResult, NetworkerError>) -> Void
    ) -> URLSessionTaskProtocol? {
        let request = self.makeURLRequest(url, method: method, modifiers: requestModifiers)
        return self.download(request, fileHandler: fileHandler, completion: completion)
    }

    @discardableResult
    public func download(
        _ urlRequest: URLRequest,
        fileHandler: ((URL) -> Void)?,
        completion: @escaping (Result<NetworkDownloaderResult, NetworkerError>) -> Void
    ) -> URLSessionTaskProtocol? {
        let operation = NetworkerOperation(
            request: urlRequest,
            executor: self.session.download(with:completion:)) { (fileURL, response, error) in
            do {
                try self.handleRemoteError(error)
                let httpResponse = try self.getHTTPResponse(from: response)
                try self.executeFilehandler(fileURL: fileURL, fileHandler: fileHandler)
                let result = self.getResult(response: httpResponse)
                self.dispatch(result, completion: completion)
            } catch {
                self.dispatch(error, completion: completion)
            }
        }

        self.queues.addOperation(operation)
        return operation.task
    }
}

private extension Networker {
    func getResult(response: HTTPURLResponse) -> NetworkDownloaderResult {
        return .init(
            statusCode: response.statusCode,
            headerFields: response.allHeaderFields
        )
    }

    func executeFilehandler(fileURL: URL?, fileHandler: ((URL) -> Void)?) throws {
        guard let url = fileURL else {
            throw NetworkerError.download(.fileURLMissing)
        }

        fileHandler?(url)
    }
}
