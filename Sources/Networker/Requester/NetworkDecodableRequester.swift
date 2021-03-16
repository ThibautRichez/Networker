//
//  NetworkDecodableRequester.swift
//  
//
//  Created by RICHEZ Thibaut on 10/25/20.
//

import Foundation

public protocol NetworkDecodableRequester {
    @discardableResult
    func request<T: Decodable>(
        _ urlConvertible: URLConvertible,
        method: HTTPMethod,
        decoder: JSONDecoder,
        requestModifiers modifiers: [NetworkerRequestModifier]?,
        responseValidators validators: [NetworkerResponseValidator]?,
        completion: @escaping (Result<T, NetworkerError>) -> Void) -> URLSessionTaskProtocol?

    @discardableResult
    func request<T: Decodable>(
        _ requestConvertible: URLRequestConvertible,
        decoder: JSONDecoder,
        responseValidators validators: [NetworkerResponseValidator]?,
        completion: @escaping (Result<T, NetworkerError>) -> Void) -> URLSessionTaskProtocol?
}

extension Networker: NetworkDecodableRequester {
    @discardableResult
    public func request<T: Decodable>(
        _ urlConvertible: URLConvertible,
        method: HTTPMethod = .get,
        decoder: JSONDecoder,
        requestModifiers modifiers: [NetworkerRequestModifier]? = nil,
        responseValidators validators: [NetworkerResponseValidator]? = nil,
        completion: @escaping (Result<T, NetworkerError>) -> Void
    ) -> URLSessionTaskProtocol? {
        self.request(urlConvertible, method: method, requestModifiers: modifiers, responseValidators: validators) { result in
            completion(self.map(result, using: decoder))
        }
    }

    @discardableResult
    public func request<T: Decodable>(
        _ requestConvertible: URLRequestConvertible,
        decoder: JSONDecoder,
        responseValidators validators: [NetworkerResponseValidator]? = nil,
        completion: @escaping (Result<T, NetworkerError>) -> Void
    ) -> URLSessionTaskProtocol? {
        self.request(requestConvertible, responseValidators: validators) { result in
            completion(self.map(result, using: decoder))
        }
    }
}

// MARK: - Helpers

private extension Networker {
    func map<T: Decodable>(
        _ result: Result<NetworkRequesterResult, NetworkerError>,
        using decoder: JSONDecoder) -> Result<T, NetworkerError> {
        result.flatMap { result in
            do {
                let model = try decoder.decode(T.self, from: result.data)
                return .success(model)
            } catch {
                return .failure(.decoder(error))
            }
        }
    }
}
