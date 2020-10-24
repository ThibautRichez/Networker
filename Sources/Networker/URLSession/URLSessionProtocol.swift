//
//  File.swift
//  
//
//  Created by RICHEZ Thibaut on 10/24/20.
//

import Foundation

protocol URLSessionProtocol {
    func request(with request: URLRequest,
                 completion: @escaping (Data?, URLResponse?, Error?) -> Void
    ) -> URLSessionTaskProtocol

    func upload(with request: URLRequest,
                from bodyData: Data?,
                completion: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionTaskProtocol

    func getTasks(completion: @escaping ([URLSessionTaskProtocol]) -> Void)
}

extension URLSession: URLSessionProtocol {
    func request(with request: URLRequest,
                 completion: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionTaskProtocol {
        return self.dataTask(with: request, completionHandler: completion) as URLSessionTaskProtocol
    }

    func upload(with request: URLRequest,
                from bodyData: Data?,
                completion: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionTaskProtocol {
        return self.uploadTask(with: request, from: bodyData, completionHandler: completion) as URLSessionTaskProtocol
    }

    func getTasks(completion: @escaping ([URLSessionTaskProtocol]) -> Void) {
        self.getAllTasks { (tasks) in
            completion(tasks as [URLSessionTaskProtocol])
        }
    }
}
