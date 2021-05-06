//
//  Networker+Dispatch.swift
//  
//
//  Created by RICHEZ Thibaut on 5/6/21.
//

import Foundation

extension Networker {
    func dispatch<T>(_ error: Error,
                     completion: @escaping (Result<T, NetworkerError>) -> Void) {
        switch error {
        case let error as NetworkerError:
            self.dispatch(.failure(error), completion: completion)
        default:
            self.dispatch(.failure(.unknown(error)), completion: completion)
        }
    }

    func dispatch<T>(_ success: T,
                     completion: @escaping (Result<T, NetworkerError>) -> Void) {
        self.dispatch(.success(success), completion: completion)
    }

    private func dispatch<T>(_ result: Result<T, NetworkerError>, completion: @escaping (Result<T, NetworkerError>) -> Void) {
        if let callbackQueue = self.queues.callback {
            callbackQueue.async { completion(result) }
        } else {
            completion(result)
        }
    }
}
