//
//  Networker+DecodableRequester.swift
//  
//
//  Created by RICHEZ Thibaut on 10/25/20.
//

import Foundation

protocol NetworkDecodableRequester: NetworkConfigurable {
    @discardableResult
    func request<T : Decodable>(type: T.Type,
                                decoder: JSONDecoder,
                                atPath path: String,
                                cachePolicy: NetworkerCachePolicy?,
                                completion: @escaping (Result<T, NetworkerError>) -> Void) -> URLSessionTaskProtocol?

    @discardableResult
    func request<T: Decodable>(type: T.Type,
                               decoder: JSONDecoder,
                               url: URL,
                               cachePolicy: NetworkerCachePolicy?,
                               completion: @escaping (Result<T, NetworkerError>) -> Void) -> URLSessionTaskProtocol

    @discardableResult
    func request<T: Decodable>(type: T.Type,
                               decoder: JSONDecoder,
                               urlRequest: URLRequest,
                               completion: @escaping (Result<T, NetworkerError>) -> Void) -> URLSessionTaskProtocol
}



extension Networker: NetworkDecodableRequester {
    @discardableResult
    func request<T: Decodable>(type: T.Type,
                               decoder: JSONDecoder,
                               atPath path: String,
                               cachePolicy: NetworkerCachePolicy? = .partial,
                               completion: @escaping (Result<T, NetworkerError>) -> Void) -> URLSessionTaskProtocol? {
        self.request(path: path, cachePolicy: cachePolicy) { result in
            completion(self.map(result, using: decoder))
        }
    }

    @discardableResult
    func request<T: Decodable>(type: T.Type,
                               decoder: JSONDecoder,
                               url: URL,
                               cachePolicy: NetworkerCachePolicy? = .partial,
                               completion: @escaping (Result<T, NetworkerError>) -> Void) -> URLSessionTaskProtocol {
        self.request(url: url, cachePolicy: cachePolicy) { result in
            completion(self.map(result, using: decoder))
        }
    }


    @discardableResult
    func request<T: Decodable>(type: T.Type,
                               decoder: JSONDecoder,
                               urlRequest: URLRequest,
                               completion: @escaping (Result<T, NetworkerError>) -> Void) -> URLSessionTaskProtocol {
        self.request(urlRequest: urlRequest) { result in
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
