//
//  File.swift
//  
//
//  Created by RICHEZ Thibaut on 10/24/20.
//

import Foundation

public protocol URLSessionProtocol {
    @discardableResult
    func request(with request: URLRequest,
                 completion: @escaping (Data?, URLResponse?, Error?) -> Void
    ) -> URLSessionTaskProtocol

    @discardableResult
    func upload(with request: URLRequest,
                from bodyData: Data?,
                completion: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionTaskProtocol

    @discardableResult
    func download(with request: URLRequest,
                  completion: @escaping (URL?, URLResponse?, Error?) -> Void) -> URLSessionTaskProtocol

    func getTasks(completion: @escaping ([URLSessionTaskProtocol]) -> Void)
}

extension URLSession: URLSessionProtocol {
    public func request(with request: URLRequest,
                 completion: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionTaskProtocol {
        return self.dataTask(with: request, completionHandler: completion)
    }

    public func upload(with request: URLRequest,
                from bodyData: Data?,
                completion: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionTaskProtocol {
        return self.uploadTask(with: request, from: bodyData, completionHandler: completion)
    }
    
    public func download(with request: URLRequest,
                  completion: @escaping (URL?, URLResponse?, Error?) -> Void) -> URLSessionTaskProtocol {
        return self.downloadTask(with: request, completionHandler: completion)
    }

    public func getTasks(completion: @escaping ([URLSessionTaskProtocol]) -> Void) {
        if #available(OSX 10.11, *) {
            self.getAllTasks { (tasks) in
                completion(tasks)
            }
        } else {
            self.getTasksWithCompletionHandler { (dataTask, uploadTask, downloadTask) in
                completion(dataTask + uploadTask + downloadTask)
            }
        }
    }
}
