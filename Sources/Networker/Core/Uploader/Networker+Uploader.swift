//
//  Networker+Uploader.swift
//  
//
//  Created by RICHEZ Thibaut on 10/25/20.
//

import Foundation

struct NetworkUploaderResult {
    var data: Data?
    var statusCode: Int
    var headerFields: [AnyHashable : Any]
}

enum NetworkUploaderType {
    case post
    case put
}

private extension NetworkUploaderType {
    var requestType: URLRequestType {
        switch self {
        case .post:
            return .post
        case .put:
            return .put
        }
    }
}

protocol NetworkUploader: NetworkConfigurable {
    @discardableResult
    func upload(path: String,
                type: NetworkUploaderType,
                data: Data?,
                cachePolicy: NetworkerCachePolicy?,
                completion: @escaping (Result<NetworkUploaderResult, NetworkerError>) -> Void) -> URLSessionTaskProtocol?

    @discardableResult
    func upload(url: URL,
                type: NetworkUploaderType,
                data: Data?,
                cachePolicy: NetworkerCachePolicy?,
                completion: @escaping (Result<NetworkUploaderResult, NetworkerError>) -> Void) -> URLSessionTaskProtocol?

    @discardableResult
    func upload(urlRequest: URLRequest,
                data: Data?,
                completion: @escaping (Result<NetworkUploaderResult, NetworkerError>) -> Void) -> URLSessionTaskProtocol?
}

extension Networker: NetworkUploader {
    @discardableResult
    func upload(path: String,
                type: NetworkUploaderType,
                data: Data?,
                cachePolicy: NetworkerCachePolicy? = .partial,
                completion: @escaping (Result<NetworkUploaderResult, NetworkerError>) -> Void) -> URLSessionTaskProtocol? {
        do {
            let uploadURL = try self.makeURL(from: path)
            return self.upload(
                url: uploadURL,
                type: type,
                data: data,
                cachePolicy: cachePolicy,
                completion: completion
            )
        } catch let error as NetworkerError {
            self.dispatch(completion: completion, with: .failure(error))
            return nil
        } catch {
            self.dispatch(completion: completion, with: .failure(.unknown(error)))
            return nil
        }
    }

    @discardableResult
    func upload(url: URL,
                type: NetworkUploaderType,
                data: Data?,
                cachePolicy: NetworkerCachePolicy? = .partial,
                completion: @escaping (Result<NetworkUploaderResult, NetworkerError>) -> Void) -> URLSessionTaskProtocol? {
        let requestType = type.requestType
        let request = self.makeURLRequest(for: requestType, cachePolicy: cachePolicy, with: url)
        return self.upload(urlRequest: request, data: data, completion: completion)
    }

    @discardableResult
    func upload(urlRequest: URLRequest,
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
                self.dispatch(completion: completion, with: .success(result))
            } catch let error as NetworkerError {
                self.dispatch(completion: completion, with: .failure(error))
            } catch {
                self.dispatch(completion: completion, with: .failure(.unknown(error)))
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

    func dispatch(completion: @escaping (Result<NetworkUploaderResult, NetworkerError>) -> Void,
                  with result: Result<NetworkUploaderResult, NetworkerError>) {
        self.queues.asyncCallback {
            completion(result)
        }
    }
}
