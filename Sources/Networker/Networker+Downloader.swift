//
//  Networker+Downloader.swift
//  
//
//  Created by RICHEZ Thibaut on 10/25/20.
//

import Foundation

struct NetworkDownloaderResult {
    var statusCode: Int
    var headerFields: [AnyHashable : Any]
}

protocol NetworkDownloader: NetworkConfigurable {
    @discardableResult
    func download(path: String,
                  requestType: URLRequestType,
                  cachePolicy: NetworkerCachePolicy?,
                  fileHandler: ((URL) -> Void)?,
                  completion: @escaping (Result<NetworkDownloaderResult, NetworkerError>) -> Void) -> URLSessionTaskProtocol?

    @discardableResult
    func download(url: URL,
                  requestType: URLRequestType,
                  cachePolicy: NetworkerCachePolicy?,
                  fileHandler: ((URL) -> Void)?,
                  completion: @escaping (Result<NetworkDownloaderResult, NetworkerError>) -> Void) -> URLSessionTaskProtocol?

    @discardableResult
    func download(urlRequest: URLRequest,
                  fileHandler: ((URL) -> Void)?,
                  completion: @escaping (Result<NetworkDownloaderResult, NetworkerError>) -> Void) -> URLSessionTaskProtocol?
}

extension Networker: NetworkDownloader {
    @discardableResult
    func download(path: String,
                  requestType: URLRequestType,
                  cachePolicy: NetworkerCachePolicy? = .partial,
                  fileHandler: ((URL) -> Void)?,
                  completion: @escaping (Result<NetworkDownloaderResult, NetworkerError>) -> Void) -> URLSessionTaskProtocol? {
        do {
            let uploadURL = try self.makeURL(from: path)
            return self.download(
                url: uploadURL,
                requestType: requestType,
                cachePolicy: cachePolicy,
                fileHandler: fileHandler,
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
    func download(url: URL,
                  requestType: URLRequestType,
                  cachePolicy: NetworkerCachePolicy? = .partial,
                  fileHandler: ((URL) -> Void)?,
                  completion: @escaping (Result<NetworkDownloaderResult, NetworkerError>) -> Void) -> URLSessionTaskProtocol? {
        let request = self.makeURLRequest(for: requestType, cachePolicy: cachePolicy, with: url)
        return self.download(urlRequest: request, fileHandler: fileHandler, completion: completion)
    }

    @discardableResult
    func download(urlRequest: URLRequest,
                  fileHandler: ((URL) -> Void)?,
                  completion: @escaping (Result<NetworkDownloaderResult, NetworkerError>) -> Void) -> URLSessionTaskProtocol? {
        let task = self.session.download(with: urlRequest) { (fileURL, response, error) in
            do {
                try self.handleRemoteError(error)
                try self.executeFilehandler(fileURL: fileURL, fileHandler: fileHandler)

                let httpResponse = try self.getHTTPResponse(from: response)
                let result = self.getResult(response: httpResponse)
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

    func dispatch(completion: @escaping (Result<NetworkDownloaderResult, NetworkerError>) -> Void,
                  with result: Result<NetworkDownloaderResult, NetworkerError>) {
        self.queues.callback.async {
            completion(result)
        }
    }
}
