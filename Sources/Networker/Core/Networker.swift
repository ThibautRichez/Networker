import Foundation

public struct Networker {
    var session: URLSessionProtocol
    var configuration: NetworkerConfiguration
    var queues: NetworkerQueuesProtocol
    var sessionReader: NetworkerSessionConfigurationReader?
    var urlConverter: URLConverter
    var acceptableMimeTypes: Set<MimeType>

    public init(session: URLSessionProtocol = URLSession.shared,
                configuration: NetworkerConfiguration = .init(),
                queues: NetworkerQueuesProtocol = NetworkerQueues(),
                sessionReader: NetworkerSessionConfigurationReader? = NetworkerSessionConfigurationRepository(),
                urlConverter: URLConverter = NetworkerURLConverter(),
                acceptableMimeTypes: Set<MimeType> = [.json]) {
        self.session = session
        self.configuration = configuration
        self.queues = queues
        self.sessionReader = sessionReader
        self.urlConverter = urlConverter
        self.acceptableMimeTypes = acceptableMimeTypes
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
        self.queues.asyncCallback {
            completion(result)
        }
    }
}
