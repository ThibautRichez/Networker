//
//  NetworkerOperation.swift
//  
//
//  Created by RICHEZ Thibaut on 10/27/20.
//

import Foundation

final class NetworkerOperation<T>: AsyncOperation {
    private(set) var task: URLSessionTaskProtocol!

    /// Creates an Async `Operation` to disptach networker tasks
    /// - Parameters:
    ///   - request: The `URLRequest` to execute
    ///   - executor: An method that takes an `URLRequest`, a `completion` and
    ///   returns an `URLSessionTaskProtocol`. (cf `Networker` request and
    ///   download for more details)
    ///   - completion: A closure that contain the executor result.
    init(request: URLRequest,
         executor: (URLRequest, (@escaping (T?, URLResponse?, Error?) -> Void)) -> URLSessionTaskProtocol,
         completion: @escaping (T?, URLResponse?, Error?) -> Void) {
        super.init()

        self.task = executor(request, { [weak self] (object, response, error) in
            completion(object, response, error)
            self?.finish()
        })
    }

    /// Creates an Async `Operation` to disptach networker tasks
    /// - Parameters:
    ///   - request: The `URLRequest` to execute
    ///   - executor: An method that takes an `URLRequest`, a `Data`, a `completion` and
    ///   returns an `URLSessionTaskProtocol`. (cf `Networker` upload for more details)
    ///   - completion: A closure that contain the executor result.
    init(request: URLRequest,
         data: Data?,
         executor: (URLRequest, Data?, (@escaping (T?, URLResponse?, Error?) -> Void)) -> URLSessionTaskProtocol,
         completion: @escaping (T?, URLResponse?, Error?) -> Void) {
        super.init()

        self.task = executor(request, data, { [weak self] (object, response, error) in
            completion(object, response, error)
            self?.finish()
        })
    }

    override func main() {
        self.task.resume()
    }

    // todo: add test (should cancel after adding a task in NetworkerCancellableTests).
    override func cancel() {
        self.task.cancel()
        super.cancel()
    }
}
