import Foundation

public struct Networker {
    var session: URLSessionProtocol
    var configuration: NetworkerConfiguration?
    var queues: NetworkerQueues

    public init(session: URLSessionProtocol = URLSession.shared,
                configuration: NetworkerConfiguration? = nil,
                queues: NetworkerQueues = .init()) {
        self.session = session
        self.configuration = configuration
        self.queues = queues
    }
}

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
