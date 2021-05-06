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
