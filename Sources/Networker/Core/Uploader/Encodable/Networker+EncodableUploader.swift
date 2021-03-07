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
        method: HTTPMethod,
        encoder: JSONEncoder,
        requestModifiers: [NetworkerRequestModifier]?,
        responseValidators: [NetworkerResponseValidator]?,
        completion: @escaping (Result<NetworkUploaderResult, NetworkerError>) -> Void
    ) -> URLSessionTaskProtocol?

    @discardableResult
    func upload<T: Encodable>(
        _ object: T,
        to url: URL,
        method: HTTPMethod,
        encoder: JSONEncoder,
        requestModifiers: [NetworkerRequestModifier]?,
        responseValidators: [NetworkerResponseValidator]?,
        completion: @escaping (Result<NetworkUploaderResult, NetworkerError>) -> Void
    ) -> URLSessionTaskProtocol?

    @discardableResult
    func upload<T: Encodable>(
        _ object: T,
        with urlRequest: URLRequest,
        encoder: JSONEncoder,
        responseValidators: [NetworkerResponseValidator]?,
        completion: @escaping (Result<NetworkUploaderResult, NetworkerError>) -> Void
    ) -> URLSessionTaskProtocol?
}

extension Networker: NetworkEncodableUploader {
    @discardableResult
    public func upload<T: Encodable>(
        _ object: T,
        to path: String,
        method: HTTPMethod = .post,
        encoder: JSONEncoder,
        requestModifiers: [NetworkerRequestModifier]? = nil,
        responseValidators: [NetworkerResponseValidator]? = nil,
        completion: @escaping (Result<NetworkUploaderResult, NetworkerError>) -> Void
    ) -> URLSessionTaskProtocol? {
        do {
            let data: Data = try encoder.encode(object)
            return self.upload(data, to: path, method: method, requestModifiers: requestModifiers, responseValidators: responseValidators, completion: completion)
        } catch {
            self.dispatch(NetworkerError.encoder(error), completion: completion)
            return nil
        }
    }

    @discardableResult
    public func upload<T: Encodable>(
        _ object: T,
        to url: URL,
        method: HTTPMethod = .post,
        encoder: JSONEncoder,
        requestModifiers: [NetworkerRequestModifier]? = nil,
        responseValidators: [NetworkerResponseValidator]? = nil,
        completion: @escaping (Result<NetworkUploaderResult, NetworkerError>) -> Void
    ) -> URLSessionTaskProtocol? {
        do {
            let data: Data = try encoder.encode(object)
            return self.upload(data, to: url, method: method, requestModifiers: requestModifiers, responseValidators: responseValidators, completion: completion)
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
        responseValidators: [NetworkerResponseValidator]? = nil,
        completion: @escaping (Result<NetworkUploaderResult, NetworkerError>) -> Void
    ) -> URLSessionTaskProtocol? {
        do {
            let data = try encoder.encode(object)
            return self.upload(data, with: urlRequest, responseValidators: responseValidators, completion: completion)
        } catch {
            self.dispatch(NetworkerError.encoder(error), completion: completion)
            return nil
        }
    }
}
