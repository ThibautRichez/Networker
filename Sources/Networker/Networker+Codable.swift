//
//  File.swift
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
                                completion: @escaping (Result<T, NetworkerError>) -> Void) -> URLSessionTaskProtocol?

    @discardableResult
    func request<T: Decodable>(type: T.Type,
                               decoder: JSONDecoder,
                               url: URL,
                               completion: @escaping (Result<T, NetworkerError>) -> Void) -> URLSessionTaskProtocol

    @discardableResult
    func request<T: Decodable>(type: T.Type,
                               decoder: JSONDecoder,
                               urlRequest: URLRequest,
                               completion: @escaping (Result<T, NetworkerError>) -> Void) -> URLSessionTaskProtocol
}

protocol NetworkEncodableUploader: NetworkConfigurable {}

protocol NetworkDecodableDownloader: NetworkConfigurable {}

protocol NetworkerCodableProtocol: NetworkDecodableRequester, NetworkEncodableUploader, NetworkDecodableDownloader, NetworkCancellable {}

// MARK: - NetworkerCodableProtocol

extension Networker: NetworkerCodableProtocol {
    func request<T: Decodable>(type: T.Type,
                               decoder: JSONDecoder,
                               atPath path: String,
                               completion: @escaping (Result<T, NetworkerError>) -> Void) -> URLSessionTaskProtocol? {
        self.request(path: path) { result in
            let decodableResult = self.convertResult(result, to: type, with: decoder)
            // already in callbackQueue.
            completion(decodableResult)
        }
    }

    @discardableResult
    func request<T: Decodable>(type: T.Type,
                               decoder: JSONDecoder,
                               url: URL,
                               completion: @escaping (Result<T, NetworkerError>) -> Void) -> URLSessionTaskProtocol {
        self.request(url: url) { result in
            let decodableResult = self.convertResult(result, to: type, with: decoder)
            // already in callbackQueue.
            completion(decodableResult)
        }
    }


    @discardableResult
    func request<T: Decodable>(type: T.Type,
                               decoder: JSONDecoder,
                               urlRequest: URLRequest,
                               completion: @escaping (Result<T, NetworkerError>) -> Void) -> URLSessionTaskProtocol {
        self.request(urlRequest: urlRequest) { result in
            let decodableResult = self.convertResult(result, to: type, with: decoder)
            // already in callbackQueue.
            completion(decodableResult)
        }
    }
}

private extension Networker {
    func decode<T: Decodable>(type: T.Type,
                              from result: NetworkerResult,
                              decoder: JSONDecoder) -> Result<T, NetworkerError> {
        do {
            let model = try decoder.decode(T.self, from: result.data)
            return .success(model)
        } catch {
            return .failure(.decoder(error))
        }

    }

    func convertResult<T: Decodable>(_ result: Result<NetworkerResult, NetworkerError>,
                                     to type: T.Type,
                                     with decoder: JSONDecoder) -> Result<T, NetworkerError> {
        switch result {
        case .success(let networkResult):
            return self.decode(type: type, from: networkResult, decoder: decoder)
        case .failure(let error):
            return .failure(error)
        }
    }
}
