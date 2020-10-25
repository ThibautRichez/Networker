//
//  File.swift
//  
//
//  Created by RICHEZ Thibaut on 10/25/20.
//

import Foundation

extension OperationQueue {
    static func networker() -> OperationQueue {
        let queue = OperationQueue()
        queue.name = "networker.operations.default.queue"
        queue.maxConcurrentOperationCount = 1
        queue.qualityOfService = .userInitiated
        return queue
    }
}
