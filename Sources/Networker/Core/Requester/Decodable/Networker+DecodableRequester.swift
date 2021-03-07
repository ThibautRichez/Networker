//
//  Networker+DecodableRequester.swift
//  
//
//  Created by RICHEZ Thibaut on 10/25/20.
//

import Foundation

public protocol NetworkDecodableRequester: NetworkConfigurable {
    @discardableResult
    func request<T : Decodable>(
        _ path: String,
        method: HTTPMethod,
        decoder: JSONDecoder,
        requestModifiers: [NetworkerRequestModifier]?,
        validators: [NetworkerResponseValidator]?,
        completion: @escaping (Result<T, NetworkerError>) -> Void) -> URLSessionTaskProtocol?

    @discardableResult
    func request<T: Decodable>(
        _ url: URL,
        method: HTTPMethod,
        decoder: JSONDecoder,
        requestModifiers: [NetworkerRequestModifier]?,
        validators: [NetworkerResponseValidator]?,
        completion: @escaping (Result<T, NetworkerError>) -> Void) -> URLSessionTaskProtocol

    @discardableResult
    func request<T: Decodable>(
        _ urlRequest: URLRequest,
        decoder: JSONDecoder,
        validators: [NetworkerResponseValidator]?,
        completion: @escaping (Result<T, NetworkerError>) -> Void) -> URLSessionTaskProtocol
}

extension Networker: NetworkDecodableRequester {
    @discardableResult
    public func request<T: Decodable>(
        _ path: String,
        method: HTTPMethod = .get,
        decoder: JSONDecoder,
        requestModifiers: [NetworkerRequestModifier]? = nil,
        validators: [NetworkerResponseValidator]? = nil,
        completion: @escaping (Result<T, NetworkerError>) -> Void) -> URLSessionTaskProtocol? {
        self.request(path, method: method, requestModifiers: requestModifiers, validators: validators) { result in
            completion(self.map(result, using: decoder))
        }
    }

    @discardableResult
    public func request<T: Decodable>(
        _ url: URL,
        method: HTTPMethod = .get,
        decoder: JSONDecoder,
        requestModifiers: [NetworkerRequestModifier]? = nil,
        validators: [NetworkerResponseValidator]? = nil,
        completion: @escaping (Result<T, NetworkerError>) -> Void) -> URLSessionTaskProtocol {
        self.request(url, method: method, requestModifiers: requestModifiers, validators: validators) { result in
            completion(self.map(result, using: decoder))
        }
    }


    @discardableResult
    public func request<T: Decodable>(
        _ urlRequest: URLRequest,
        decoder: JSONDecoder,
        validators: [NetworkerResponseValidator]? = nil,
        completion: @escaping (Result<T, NetworkerError>) -> Void) -> URLSessionTaskProtocol {
        self.request(urlRequest, validators: validators) { result in
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
