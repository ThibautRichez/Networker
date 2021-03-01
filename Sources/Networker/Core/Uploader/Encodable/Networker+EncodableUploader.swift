//
//  File.swift
//  
//
//  Created by RICHEZ Thibaut on 10/25/20.
//

import Foundation

public protocol NetworkEncodableUploader: NetworkConfigurable {
    @discardableResult
    func upload<T: Encodable>(
        path: String,
        type: NetworkUploaderType,
        model: T?,
        encoder: JSONEncoder,
        options: [NetworkerOption]?,
        completion: @escaping (Result<NetworkUploaderResult, NetworkerError>) -> Void
    ) -> URLSessionTaskProtocol?

    @discardableResult
    func upload<T: Encodable>(
        url: URL,
        type: NetworkUploaderType,
        model: T?,
        encoder: JSONEncoder,
        options: [NetworkerOption]?,
        completion: @escaping (Result<NetworkUploaderResult, NetworkerError>) -> Void
    ) -> URLSessionTaskProtocol?

    @discardableResult
    func upload<T: Encodable>(
        urlRequest: URLRequest,
        model: T?,
        encoder: JSONEncoder,
        completion: @escaping (Result<NetworkUploaderResult, NetworkerError>) -> Void
    ) -> URLSessionTaskProtocol?
}

extension Networker: NetworkEncodableUploader {
    @discardableResult
    public func upload<T: Encodable>(
        path: String,
        type: NetworkUploaderType,
        model: T?,
        encoder: JSONEncoder,
        options: [NetworkerOption]? = nil,
        completion: @escaping (Result<NetworkUploaderResult, NetworkerError>) -> Void
    ) -> URLSessionTaskProtocol? {
        do {
            let data: Data = try encoder.encode(model)
            return self.upload(
                path: path, type: type, data: data,
                options: options, completion: completion
            )
        } catch {
            self.dispatch(NetworkerError.encoder(error), completion: completion)
            return nil
        }
    }

    @discardableResult
    public func upload<T: Encodable>(
        url: URL,
        type: NetworkUploaderType,
        model: T?,
        encoder: JSONEncoder,
        options: [NetworkerOption]? = nil,
        completion: @escaping (Result<NetworkUploaderResult, NetworkerError>) -> Void
    ) -> URLSessionTaskProtocol? {
        do {
            let data: Data = try encoder.encode(model)
            return self.upload(
                url: url, type: type, data: data,
                options: options, completion: completion
            )
        } catch {
            self.dispatch(NetworkerError.encoder(error), completion: completion)
            return nil
        }
    }

    @discardableResult
    public func upload<T: Encodable>(
        urlRequest: URLRequest,
        model: T?,
        encoder: JSONEncoder,
        completion: @escaping (Result<NetworkUploaderResult, NetworkerError>) -> Void
    ) -> URLSessionTaskProtocol? {
        do {
            let data = try encoder.encode(model)
            return self.upload(urlRequest: urlRequest, data: data, completion: completion)
        } catch {
            self.dispatch(NetworkerError.encoder(error), completion: completion)
            return nil
        }
    }
}
