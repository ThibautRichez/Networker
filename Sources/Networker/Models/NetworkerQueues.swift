//
//  NetworkerQueues.swift
//  
//
//  Created by RICHEZ Thibaut on 10/25/20.
//

import Foundation

public struct NetworkerQueues {
    /// A queue that regulates the execution of network operations
    /// (cf. `OperationQueue` documentation for more details).
    public var operation: OperationQueue

    /// The queue in which the `completion` closures are called.
    /// If `nil`, it will stay on whichever queue the system
    /// is currently on. In that case, it is your reponsability
    /// to switch back on the right queue if/when necessary.
    public var callback: DispatchQueue?

    public init(operation: OperationQueue = .networker(),
                callback: DispatchQueue? = nil) {
        self.operation = operation
        self.callback = callback
    }
}
