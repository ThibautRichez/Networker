//
//  Networker+Cancellable.swift
//  
//
//  Created by RICHEZ Thibaut on 10/25/20.
//

import Foundation

public protocol NetworkCancellable {
    func cancelTask(with identifier: Int, completion: (() -> Void)?)
    func cancelTasks(completion: (() -> Void)?)
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
        self.queues.cancelAllOperations()
    }
}
