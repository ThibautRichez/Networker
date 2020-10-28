import Foundation

struct Networker {
    var session: URLSessionProtocol = URLSession.shared
    var configuration: NetworkerConfiguration = .init()
    var queues: NetworkerQueuesProtocol = NetworkerQueues()
    var sessionReader: NetworkerSessionConfigurationReader? = NetworkerSessionConfigurationRepository()
    var acceptableMimeTypes: Set<MimeType> = [.json]
}
