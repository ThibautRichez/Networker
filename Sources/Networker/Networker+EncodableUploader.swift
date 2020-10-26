//
//  File.swift
//  
//
//  Created by RICHEZ Thibaut on 10/25/20.
//

import Foundation

protocol NetworkEncodableUploader: NetworkConfigurable {
    @discardableResult
    func upload<T: Encodable>(path: String,
                              type: NetworkUploaderType,
                              model: T?,
                              encoder: JSONEncoder,
                              cachePolicy: NetworkerCachePolicy,
                              completion: @escaping (Result<NetworkUploaderResult, NetworkerError>) -> Void) -> URLSessionTaskProtocol?

    @discardableResult
    func upload<T: Encodable>(url: URL,
                              type: NetworkUploaderType,
                              model: T?,
                              encoder: JSONEncoder,
                              cachePolicy: NetworkerCachePolicy,
                              completion: @escaping (Result<NetworkUploaderResult, NetworkerError>) -> Void) -> URLSessionTaskProtocol?

    @discardableResult
    func upload<T: Encodable>(urlRequest: URLRequest,
                              model: T?,
                              encoder: JSONEncoder,
                              completion: @escaping (Result<NetworkUploaderResult, NetworkerError>) -> Void) -> URLSessionTaskProtocol?
}

extension Networker: NetworkEncodableUploader {
    func upload<T: Encodable>(path: String,
                   type: NetworkUploaderType,
                   model: T?,
                   encoder: JSONEncoder,
                   cachePolicy: NetworkerCachePolicy = .partial,
                   completion: @escaping (Result<NetworkUploaderResult, NetworkerError>) -> Void) -> URLSessionTaskProtocol? {
        do {
            let data: Data? = try encoder.encode(model)
            return self.upload(
                path: path,
                type: type,
                data: data,
                cachePolicy: cachePolicy,
                completion: completion
            )
        } catch {
            self.dispatch(completion: completion, with: .failure(.encoder(error)))
            return nil
        }
    }

    func upload<T: Encodable>(url: URL,
                              type: NetworkUploaderType,
                              model: T?,
                              encoder: JSONEncoder,
                              cachePolicy: NetworkerCachePolicy = .partial,
                              completion: @escaping (Result<NetworkUploaderResult, NetworkerError>) -> Void) -> URLSessionTaskProtocol? {
        do {
            let data: Data? = try encoder.encode(model)
            return self.upload(
                url: url,
                type: type,
                data: data,
                cachePolicy: cachePolicy,
                completion: completion
            )
        } catch {
            self.dispatch(completion: completion, with: .failure(.encoder(error)))
            return nil
        }
    }

    func upload<T: Encodable>(urlRequest: URLRequest,
                              model: T?,
                              encoder: JSONEncoder,
                              completion: @escaping (Result<NetworkUploaderResult, NetworkerError>) -> Void) -> URLSessionTaskProtocol? {
        do {
            let data: Data? = try encoder.encode(model)
            return self.upload(urlRequest: urlRequest, data: data, completion: completion)
        } catch {
            self.dispatch(completion: completion, with: .failure(.encoder(error)))
            return nil
        }
    }
}
