//
//  NetworkerQueues.swift
//  
//
//  Created by RICHEZ Thibaut on 10/25/20.
//

import Foundation

protocol NetworkerQueuesProtocol {
    func asyncCallback(execute work: @escaping () -> Void)
    func addOperation(_ operation: Operation)
    func cancelAllOperations()
}

struct NetworkerQueues {
    var operations: OperationQueue = .networker()
    var callback: DispatchQueue = .main
}

extension NetworkerQueues: NetworkerQueuesProtocol {
    func asyncCallback(execute work: @escaping () -> Void) {
        self.callback.async(execute: work)
    }

    func addOperation(_ operation: Operation) {
        self.operations.addOperation(operation)
    }

    func cancelAllOperations() {
        self.operations.cancelAllOperations()
    }
}
