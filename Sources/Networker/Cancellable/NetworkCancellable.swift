//
//  NetworkCancellable.swift
//  
//
//  Created by RICHEZ Thibaut on 10/25/20.
//

import Foundation

public protocol NetworkCancellable {
    /// Cancels the underlying `URLSessionProtocol` task associated
    /// with the given identifier.
    func cancelTask(with identifier: Int, completion: (() -> Void)?)

    /// Cancels all underlying `URLSessionProtocol` tasks.
    func cancelTasks(completion: (() -> Void)?)

    /// Cancels all ongoing operations in the `OperationQueue`.
    /// (cf. `OperationQueue.cancelAllOperations` documentation)
    func cancelAllOperations()
}

extension Networker: NetworkCancellable {
    public func cancelTask(with identifier: Int, completion: (() -> Void)?) {
        self.session.getTasks { (tasks) in
            let task = tasks.first { $0.taskIdentifier == identifier }
            task?.cancel()
            completion?()
        }
    }

    public func cancelTasks(completion: (() -> Void)?) {
        self.session.getTasks { (tasks) in
            tasks.forEach { $0.cancel() }
            completion?()
        }
    }

    public func cancelAllOperations() {
        self.queues.operation.cancelAllOperations()
    }
}
