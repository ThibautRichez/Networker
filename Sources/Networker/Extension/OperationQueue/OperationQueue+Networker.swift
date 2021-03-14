//
//  File.swift
//  
//
//  Created by RICHEZ Thibaut on 10/25/20.
//

import Foundation

extension OperationQueue {
    /// Default queue used by `Networker` instances.
    /// (cf. `NetworkerQueues` to specify your own)
    public static func networker() -> OperationQueue {
        let queue = OperationQueue()
        queue.maxConcurrentOperationCount = 1
        queue.qualityOfService = .default
        return queue
    }
}
