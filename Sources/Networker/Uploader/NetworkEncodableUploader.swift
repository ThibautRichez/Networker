//
//  NetworkEncodableUploader.swift
//  
//
//  Created by RICHEZ Thibaut on 10/25/20.
//

import Foundation

public protocol NetworkEncodableUploader {
    @discardableResult
    func upload<T: Encodable>(
        _ object: T,
        to url: URLConvertible,
        method: HTTPMethod,
        encoder: JSONEncoder,
        requestModifiers modifiers: [NetworkerRequestModifier]?,
        responseValidators validators: [NetworkerResponseValidator]?,
        completion: @escaping (Result<NetworkUploaderResult, NetworkerError>) -> Void
    ) -> URLSessionTaskProtocol?

    @discardableResult
    func upload<T: Encodable>(
        _ object: T,
        with request: URLRequestConvertible,
        encoder: JSONEncoder,
        responseValidators validators: [NetworkerResponseValidator]?,
        completion: @escaping (Result<NetworkUploaderResult, NetworkerError>) -> Void
    ) -> URLSessionTaskProtocol?
}

extension Networker: NetworkEncodableUploader {
    @discardableResult
    public func upload<T: Encodable>(
        _ object: T,
        to url: URLConvertible,
        method: HTTPMethod = .post,
        encoder: JSONEncoder,
        requestModifiers modifiers: [NetworkerRequestModifier]? = nil,
        responseValidators validators: [NetworkerResponseValidator]? = nil,
        completion: @escaping (Result<NetworkUploaderResult, NetworkerError>) -> Void
    ) -> URLSessionTaskProtocol? {
        do {
            let data: Data = try encoder.encode(object)
            return self.upload(data, to: url, method: method, requestModifiers: modifiers, responseValidators: validators, completion: completion)
        } catch {
            self.dispatch(NetworkerError.encoder(error), completion: completion)
            return nil
        }
    }

    @discardableResult
    public func upload<T: Encodable>(
        _ object: T,
        with request: URLRequestConvertible,
        encoder: JSONEncoder,
        responseValidators validators: [NetworkerResponseValidator]? = nil,
        completion: @escaping (Result<NetworkUploaderResult, NetworkerError>) -> Void
    ) -> URLSessionTaskProtocol? {
        do {
            let data = try encoder.encode(object)
            return self.upload(data, with: request, responseValidators: validators, completion: completion)
        } catch {
            self.dispatch(NetworkerError.encoder(error), completion: completion)
            return nil
        }
    }
}
