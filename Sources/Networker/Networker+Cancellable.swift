//
//  Networker+Cancellable.swift
//  
//
//  Created by RICHEZ Thibaut on 10/25/20.
//

import Foundation

protocol NetworkCancellable {
    func cancelTask(with identifier: Int, completion: (() -> Void)?)
    func cancelTasks(completion: (() -> Void)?)
}

extension Networker: NetworkCancellable {
    func cancelTask(with identifier: Int, completion: (() -> Void)?) {
        self.session.getTasks { (tasks) in
            let task = tasks.first { $0.taskIdentifier == identifier }
            task?.cancel()
            completion?()
        }
    }

    func cancelTasks(completion: (() -> Void)?) {
        self.session.getTasks { (tasks) in
            tasks.forEach { $0.cancel() }
            completion?()
        }
    }
}
