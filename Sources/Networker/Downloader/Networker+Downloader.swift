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

public protocol NetworkDownloader {
    @discardableResult
    func download(
        _ urlConvertible: URLConvertible,
        method: HTTPMethod,
        fileHandler: ((URL) -> Void)?,
        requestModifiers: [NetworkerRequestModifier]?,
        responseValidators: [NetworkerResponseValidator]?,
        completion: @escaping (Result<NetworkDownloaderResult, NetworkerError>) -> Void
    ) -> URLSessionTaskProtocol?

    @discardableResult
    func download(
        _ requestConvertible: URLRequestConvertible,
        fileHandler: ((URL) -> Void)?,
        responseValidators: [NetworkerResponseValidator]?,
        completion: @escaping (Result<NetworkDownloaderResult, NetworkerError>
        ) -> Void) -> URLSessionTaskProtocol?
}

extension Networker: NetworkDownloader {
    @discardableResult
    public func download(
        _ urlConvertible: URLConvertible,
        method: HTTPMethod = .get,
        fileHandler: ((URL) -> Void)?,
        requestModifiers: [NetworkerRequestModifier]? = nil,
        responseValidators: [NetworkerResponseValidator]? = nil,
        completion: @escaping (Result<NetworkDownloaderResult, NetworkerError>) -> Void
    ) -> URLSessionTaskProtocol? {
        do {
            let url = try urlConvertible.asURL(relativeTo: self.configuration?.baseURL)
            let request = self.makeURLRequest(url, method: method, modifiers: requestModifiers)
            return self.download(request, fileHandler: fileHandler, responseValidators: responseValidators, completion: completion)
        } catch {
            self.dispatch(error, completion: completion)
            return nil
        }
    }

    @discardableResult
    public func download(
        _ requestConvertible: URLRequestConvertible,
        fileHandler: ((URL) -> Void)?,
        responseValidators: [NetworkerResponseValidator]? = nil,
        completion: @escaping (Result<NetworkDownloaderResult, NetworkerError>) -> Void
    ) -> URLSessionTaskProtocol? {
        do {
            let request = try requestConvertible.asURLRequest()
            return self.download(request, fileHandler: fileHandler, responseValidators: responseValidators, completion: completion)
        } catch {
            self.dispatch(error, completion: completion)
            return nil
        }
    }
}

private extension Networker {
    func download(
        _ request: URLRequest,
        fileHandler: ((URL) -> Void)?,
        responseValidators: [NetworkerResponseValidator]? = nil,
        completion: @escaping (Result<NetworkDownloaderResult, NetworkerError>) -> Void
    ) -> URLSessionTaskProtocol? {
        let operation = NetworkerOperation(
            request: request,
            executor: self.session.download(with:completion:)) { (fileURL, response, error) in
            do {
                try self.handleRemoteError(error)
                let httpResponse = try self.getHTTPResponse(from: response, validators: responseValidators)
                try self.executeFilehandler(fileURL: fileURL, fileHandler: fileHandler)
                let result = self.getResult(response: httpResponse)
                self.dispatch(result, completion: completion)
            } catch {
                self.dispatch(error, completion: completion)
            }
        }

        self.queues.operation.addOperation(operation)
        return operation.task
    }

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
