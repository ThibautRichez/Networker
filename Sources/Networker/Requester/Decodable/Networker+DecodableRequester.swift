//
//  Networker+DecodableRequester.swift
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
        requestModifiers: [NetworkerRequestModifier]?,
        responseValidators: [NetworkerResponseValidator]?,
        completion: @escaping (Result<T, NetworkerError>) -> Void) -> URLSessionTaskProtocol?

    @discardableResult
    func request<T: Decodable>(
        _ requestConvertible: URLRequestConvertible,
        decoder: JSONDecoder,
        responseValidators: [NetworkerResponseValidator]?,
        completion: @escaping (Result<T, NetworkerError>) -> Void) -> URLSessionTaskProtocol?
}

extension Networker: NetworkDecodableRequester {
    @discardableResult
    public func request<T: Decodable>(
        _ urlConvertible: URLConvertible,
        method: HTTPMethod = .get,
        decoder: JSONDecoder,
        requestModifiers: [NetworkerRequestModifier]? = nil,
        responseValidators: [NetworkerResponseValidator]? = nil,
        completion: @escaping (Result<T, NetworkerError>) -> Void) -> URLSessionTaskProtocol? {
        self.request(urlConvertible, method: method, requestModifiers: requestModifiers, responseValidators: responseValidators) { result in
            completion(self.map(result, using: decoder))
        }
    }

    @discardableResult
    public func request<T: Decodable>(
        _ requestConvertible: URLRequestConvertible,
        decoder: JSONDecoder,
        responseValidators: [NetworkerResponseValidator]? = nil,
        completion: @escaping (Result<T, NetworkerError>) -> Void) -> URLSessionTaskProtocol? {
        self.request(requestConvertible, responseValidators: responseValidators) { result in
            completion(self.map(result, using: decoder))
        }
    }
}

// MARK: - Helpers

private extension Networker {
    func map<T: Decodable>(
        _ result: Result<NetworkRequesterResult, NetworkerError>,
        using decoder: JSONDecoder) -> Result<T, NetworkerError> {
        result.flatMap { requesterResult in
            do {
                let model = try decoder.decode(T.self, from: requesterResult.data)
                return .success(model)
            } catch {
                return .failure(.decoder(error))
            }
        }
    }
}
