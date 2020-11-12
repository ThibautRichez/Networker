import Foundation

struct Networker {
    var session: URLSessionProtocol = URLSession.shared
    var configuration: NetworkerConfiguration = .init()
    var queues: NetworkerQueuesProtocol = NetworkerQueues()
    var sessionReader: NetworkerSessionConfigurationReader? = NetworkerSessionConfigurationRepository()
    var urlConverter: URLConverter = NetworkerURLConverter()
    var acceptableMimeTypes: Set<MimeType> = [.json]
}

extension Networker {
    func dispatch<T>(completion: @escaping (Result<T, NetworkerError>) -> Void,
                     with result: Result<T, NetworkerError>) {
        self.queues.asyncCallback {
            completion(result)
        }
    }
}
