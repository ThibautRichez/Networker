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
        _ object: T,
        to path: String,
        type: NetworkUploaderType,
        encoder: JSONEncoder,
        options: [NetworkerOption]?,
        completion: @escaping (Result<NetworkUploaderResult, NetworkerError>) -> Void
    ) -> URLSessionTaskProtocol?

    @discardableResult
    func upload<T: Encodable>(
        _ object: T,
        to url: URL,
        type: NetworkUploaderType,
        encoder: JSONEncoder,
        options: [NetworkerOption]?,
        completion: @escaping (Result<NetworkUploaderResult, NetworkerError>) -> Void
    ) -> URLSessionTaskProtocol?

    @discardableResult
    func upload<T: Encodable>(
        _ object: T,
        with urlRequest: URLRequest,
        encoder: JSONEncoder,
        completion: @escaping (Result<NetworkUploaderResult, NetworkerError>) -> Void
    ) -> URLSessionTaskProtocol?
}

extension Networker: NetworkEncodableUploader {
    @discardableResult
    public func upload<T: Encodable>(
        _ object: T,
        to path: String,
        type: NetworkUploaderType,
        encoder: JSONEncoder,
        options: [NetworkerOption]? = nil,
        completion: @escaping (Result<NetworkUploaderResult, NetworkerError>) -> Void
    ) -> URLSessionTaskProtocol? {
        do {
            let data: Data = try encoder.encode(object)
            return self.upload(data, to: path, type: type, options: options, completion: completion)
        } catch {
            self.dispatch(NetworkerError.encoder(error), completion: completion)
            return nil
        }
    }

    @discardableResult
    public func upload<T: Encodable>(
        _ object: T,
        to url: URL,
        type: NetworkUploaderType,
        encoder: JSONEncoder,
        options: [NetworkerOption]? = nil,
        completion: @escaping (Result<NetworkUploaderResult, NetworkerError>) -> Void
    ) -> URLSessionTaskProtocol? {
        do {
            let data: Data = try encoder.encode(object)
            return self.upload(data, to: url, type: type, options: options, completion: completion)
        } catch {
            self.dispatch(NetworkerError.encoder(error), completion: completion)
            return nil
        }
    }

    @discardableResult
    public func upload<T: Encodable>(
        _ object: T,
        with urlRequest: URLRequest,
        encoder: JSONEncoder,
        completion: @escaping (Result<NetworkUploaderResult, NetworkerError>) -> Void
    ) -> URLSessionTaskProtocol? {
        do {
            let data = try encoder.encode(object)
            return self.upload(data, with: urlRequest, completion: completion)
        } catch {
            self.dispatch(NetworkerError.encoder(error), completion: completion)
            return nil
        }
    }
}
