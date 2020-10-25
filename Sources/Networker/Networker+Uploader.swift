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
                completion: @escaping (Result<NetworkUploaderResult, NetworkerError>) -> Void) -> URLSessionTaskProtocol?

    @discardableResult
    func upload(url: URL,
                type: NetworkUploaderType,
                data: Data?,
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
                completion: @escaping (Result<NetworkUploaderResult, NetworkerError>) -> Void) -> URLSessionTaskProtocol? {
        do {
            let uploadURL = try self.makeURL(from: path)
            return self.upload(url: uploadURL, type: type, data: data, completion: completion)
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
                completion: @escaping (Result<NetworkUploaderResult, NetworkerError>) -> Void) -> URLSessionTaskProtocol? {
        let urlRequest = self.makeURLRequest(for: type.requestType, with: url)
        return self.upload(urlRequest: urlRequest, data: data, completion: completion)
    }

    @discardableResult
    func upload(urlRequest: URLRequest,
                data: Data?,
                completion: @escaping (Result<NetworkUploaderResult, NetworkerError>) -> Void) -> URLSessionTaskProtocol? {
        let task = self.session.upload(with: urlRequest, from: data) { (data, response, error) in
            do {
                try self.handleRemoteError(error)
                let httpResponse = try self.getHTTPResponse(from: response)
                let result = try self.getResult(with: data, response: httpResponse)
                self.dispatch(completion: completion, with: .success(result))
            } catch let error as NetworkerError {
                self.dispatch(completion: completion, with: .failure(error))
            } catch {
                self.dispatch(completion: completion, with: .failure(.unknown(error)))
            }
        }

        self.addTask(task)

        return task
    }
}

// MARK: - Helpers

extension Networker {
    private func getResult(with data: Data?, response: HTTPURLResponse) throws -> NetworkUploaderResult {
        return .init(
            data: data,
            statusCode: response.statusCode,
            headerFields: response.allHeaderFields
        )
    }

    func dispatch(completion: @escaping (Result<NetworkUploaderResult, NetworkerError>) -> Void,
                  with result: Result<NetworkUploaderResult, NetworkerError>) {
        self.queues.callback.async {
            completion(result)
        }
    }
}
