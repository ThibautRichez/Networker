//
//  File.swift
//  
//
//  Created by RICHEZ Thibaut on 10/25/20.
//

import Foundation

public protocol NetworkEncodableUploader {
    @discardableResult
    func upload<T: Encodable>(
        _ object: T,
        to urlConvertible: URLConvertible,
        method: HTTPMethod,
        encoder: JSONEncoder,
        requestModifiers: [NetworkerRequestModifier]?,
        responseValidators: [NetworkerResponseValidator]?,
        completion: @escaping (Result<NetworkUploaderResult, NetworkerError>) -> Void
    ) -> URLSessionTaskProtocol?

    @discardableResult
    func upload<T: Encodable>(
        _ object: T,
        with requestConvertible: URLRequestConvertible,
        encoder: JSONEncoder,
        responseValidators: [NetworkerResponseValidator]?,
        completion: @escaping (Result<NetworkUploaderResult, NetworkerError>) -> Void
    ) -> URLSessionTaskProtocol?
}

extension Networker: NetworkEncodableUploader {
    @discardableResult
    public func upload<T: Encodable>(
        _ object: T,
        to urlConvertible: URLConvertible,
        method: HTTPMethod = .post,
        encoder: JSONEncoder,
        requestModifiers: [NetworkerRequestModifier]? = nil,
        responseValidators: [NetworkerResponseValidator]? = nil,
        completion: @escaping (Result<NetworkUploaderResult, NetworkerError>) -> Void
    ) -> URLSessionTaskProtocol? {
        do {
            let data: Data = try encoder.encode(object)
            return self.upload(data, to: urlConvertible, method: method, requestModifiers: requestModifiers, responseValidators: responseValidators, completion: completion)
        } catch {
            self.dispatch(NetworkerError.encoder(error), completion: completion)
            return nil
        }
    }

    @discardableResult
    public func upload<T: Encodable>(
        _ object: T,
        with requestConvertible: URLRequestConvertible,
        encoder: JSONEncoder,
        responseValidators: [NetworkerResponseValidator]? = nil,
        completion: @escaping (Result<NetworkUploaderResult, NetworkerError>) -> Void
    ) -> URLSessionTaskProtocol? {
        do {
            let data = try encoder.encode(object)
            return self.upload(data, with: requestConvertible, responseValidators: responseValidators, completion: completion)
        } catch {
            self.dispatch(NetworkerError.encoder(error), completion: completion)
            return nil
        }
    }
}
