//
//  NetworkerQueues.swift
//  
//
//  Created by RICHEZ Thibaut on 10/25/20.
//

import Foundation

public protocol NetworkerQueuesProtocol {
    func asyncCallback(execute work: @escaping () -> Void)
    func addOperation(_ operation: Operation)
    func cancelAllOperations()
}

public struct NetworkerQueues {
    public var operations: OperationQueue
    public var callback: DispatchQueue

    public init(operations: OperationQueue = .networker(),
                callback: DispatchQueue = .main) {
        self.operations = operations
        self.callback = callback
    }
}

extension NetworkerQueues: NetworkerQueuesProtocol {
    public func asyncCallback(execute work: @escaping () -> Void) {
        self.callback.async(execute: work)
    }

    public func addOperation(_ operation: Operation) {
        self.operations.addOperation(operation)
    }

    public func cancelAllOperations() {
        self.operations.cancelAllOperations()
    }
}
