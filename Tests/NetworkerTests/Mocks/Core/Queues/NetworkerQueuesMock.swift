//
//  NetworkerQueuesMock.swift
//  
//
//  Created by RICHEZ Thibaut on 10/28/20.
//

import Foundation
@testable import Networker

final class NetworkerQueuesMock: NetworkerQueuesProtocol {
    var appQueues = NetworkerQueues()

    var asyncCallbackCallCount = 0
    var didCallAsyncCallback: Bool {
        self.asyncCallbackCallCount > 0
    }

    var addOperationCallCount = 0
    var didCallAddOperation: Bool {
        self.addOperationCallCount > 0
    }

    var cancelAllOperationsCallCount = 0
    var didCallCancelAllOperations: Bool {
        self.cancelAllOperationsCallCount > 0
    }

    func asyncCallback(execute work: @escaping () -> Void) {
        self.asyncCallbackCallCount += 1
        self.appQueues.asyncCallback(execute: work)
    }

    func addOperation(_ operation: Operation) {
        self.addOperationCallCount += 1
        self.appQueues.addOperation(operation)
    }

    func cancelAllOperations() {
        self.cancelAllOperationsCallCount += 1
        self.appQueues.cancelAllOperations()
    }
}
