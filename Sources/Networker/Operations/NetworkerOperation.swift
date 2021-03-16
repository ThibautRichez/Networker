//
//  NetworkerOperation.swift
//  
//
//  Created by RICHEZ Thibaut on 10/27/20.
//

import Foundation

public enum NetworkerRetryPolicy {
    case after(delay: TimeInterval) // how to create delay without retaining current Operation? scheduler?
    case count(Int)
}

public protocol NetworkerOperationProtocol {
    var taskIdentifier: Int { get }

    func cancel()
    @discardableResult
    func then(completion: @escaping () -> Void) -> NetworkerOperationProtocol
    @discardableResult
    func retry(_ policy: NetworkerRetryPolicy) -> NetworkerOperationProtocol
}

final class NetworkerOperation: AsyncOperation {
    private(set) var task: URLSessionTaskProtocol!

    private var thenCompletions = [() -> Void]()

    /// Creates an Async `Operation` to disptach networker tasks
    /// - Parameters:
    ///   - request: The `URLRequest` to execute
    ///   - executor: An method that takes an `URLRequest`, a `completion` and
    ///   returns an `URLSessionTaskProtocol`. (cf `Networker` request and
    ///   download for more details)
    ///   - completion: A closure that contain the executor result.
    init<T>(request: URLRequest,
         executor: (URLRequest, (@escaping (T?, URLResponse?, Error?) -> Void)) -> URLSessionTaskProtocol,
         completion: @escaping (T?, URLResponse?, Error?) -> Void) {
        super.init()

        self.task = executor(request, { [weak self] (object, response, error) in
            completion(object, response, error)
            self?.executeThenCompletions()
            self?.finish()
        })
    }

    /// Creates an Async `Operation` to disptach networker tasks
    /// - Parameters:
    ///   - request: The `URLRequest` to execute
    ///   - executor: An method that takes an `URLRequest`, a `Data`, a `completion` and
    ///   returns an `URLSessionTaskProtocol`. (cf `Networker` upload for more details)
    ///   - completion: A closure that contain the executor result.
    init<T>(request: URLRequest,
         data: Data?,
         executor: (URLRequest, Data?, (@escaping (T?, URLResponse?, Error?) -> Void)) -> URLSessionTaskProtocol,
         completion: @escaping (T?, URLResponse?, Error?) -> Void) {
        super.init()

        self.task = executor(request, data, { [weak self] (object, response, error) in
            completion(object, response, error)
            self?.executeThenCompletions()
            self?.finish()
        })
    }

    override func main() {
        self.task.resume()
    }

    override func cancel() {
        self.task.cancel()
        super.cancel()
    }

    private func executeThenCompletions() {
        self.thenCompletions.forEach { $0() }
        self.thenCompletions.removeAll()
    }
}

// MARK: - NetworkerOperationProtocol

extension NetworkerOperation: NetworkerOperationProtocol {
    public var taskIdentifier: Int { self.task.taskIdentifier }

    @discardableResult
    public func then(completion: @escaping () -> Void) -> NetworkerOperationProtocol {
        self.thenCompletions.append(completion)
        return self
    }

    @discardableResult
    public func retry(_ policy: NetworkerRetryPolicy) -> NetworkerOperationProtocol {
        // lets work
        return self
    }
}
