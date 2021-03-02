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
        options: [NetworkerOption]?,
        completion: @escaping (Result<T, NetworkerError>) -> Void) -> URLSessionTaskProtocol?

    @discardableResult
    func request<T: Decodable>(
        _ url: URL,
        method: HTTPMethod,
        decoder: JSONDecoder,
        options: [NetworkerOption]?,
        completion: @escaping (Result<T, NetworkerError>) -> Void) -> URLSessionTaskProtocol

    @discardableResult
    func request<T: Decodable>(
        _ urlRequest: URLRequest,
        decoder: JSONDecoder,
        completion: @escaping (Result<T, NetworkerError>) -> Void) -> URLSessionTaskProtocol
}

extension Networker: NetworkDecodableRequester {
    @discardableResult
    public func request<T: Decodable>(
        _ path: String,
        method: HTTPMethod = .get,
        decoder: JSONDecoder,
        options: [NetworkerOption]? = nil,
        completion: @escaping (Result<T, NetworkerError>) -> Void) -> URLSessionTaskProtocol? {
        self.request(path, method: method, options: options) { result in
            completion(self.map(result, using: decoder))
        }
    }

    @discardableResult
    public func request<T: Decodable>(
        _ url: URL,
        method: HTTPMethod = .get,
        decoder: JSONDecoder,
        options: [NetworkerOption]? = nil,
        completion: @escaping (Result<T, NetworkerError>) -> Void) -> URLSessionTaskProtocol {
        self.request(url, method: method, options: options) { result in
            completion(self.map(result, using: decoder))
        }
    }


    @discardableResult
    public func request<T: Decodable>(
        _ urlRequest: URLRequest,
        decoder: JSONDecoder,
        completion: @escaping (Result<T, NetworkerError>) -> Void) -> URLSessionTaskProtocol {
        self.request(urlRequest) { result in
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
