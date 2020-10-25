import Foundation

protocol NetworkEncodableUploader: NetworkConfigurable {}

protocol NetworkDownloader: NetworkConfigurable {}
protocol NetworkDecodableDownloader: NetworkConfigurable {}

struct Networker {
    var session: URLSessionProtocol = URLSession.shared
    var configuration: NetworkerConfiguration = .init()
    var queues: NetworkerQueues = .init()
    var sessionReader: NetworkerSessionConfigurationReader? = NetworkerSessionConfigurationRepository.shared
    var acceptableMimeTypes: Set<MimeType> = [.json]
}

// MARK: - Helpers

extension Networker {
    func makeURL(from path: String) throws -> URL {
        if path.isAbsoluteURL {
            guard let absoluteURL = URL(string: path) else {
                throw NetworkerError.path(.invalidAbsolutePath(path))
            }
            return absoluteURL
        }

        let baseURL = try self.makeBaseURL()
        let token = self.configuration.token ?? self.sessionConfiguration?.token ?? ""
        return baseURL
            .appendingPathComponent(token)
            .appendingPathComponent(path)
    }

    func makeURLRequest(for type: URLRequestType,
                        with url: URL) -> URLRequest {
        var urlRequest = URLRequest(url: url, timeoutInterval: self.configuration.timeoutInterval)
        urlRequest.httpMethod = type.rawValue
        return urlRequest
    }

    func getHTTPResponse(from response: URLResponse?) throws -> HTTPURLResponse {
        guard let response = response else {
            throw NetworkerError.response(.empty)
        }

        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkerError.response(.invalid(response))
        }

        guard (200...299).contains(httpResponse.statusCode) else {
            throw NetworkerError.response(.statusCode(httpResponse))
        }

        let acceptableMimeTypes = self.acceptableMimeTypes.map { $0.rawValue }
        guard let mimeType = httpResponse.mimeType,
              acceptableMimeTypes.contains(mimeType) else {
            throw NetworkerError.response(
                .invalidMimeType(got: httpResponse.mimeType, allowed: acceptableMimeTypes)
            )
        }

        return httpResponse
    }

    func handleRemoteError(_ error: Error?) throws {
        if let error = error {
            throw NetworkerError.remote(NetworkerRemoteError(error))
        }
    }

    func addTask(_ task: URLSessionTaskProtocol) {
        self.queues.operations.addOperation {
            task.resume()
        }
    }
}

extension Networker {
    private var sessionConfiguration: NetworkerSessionConfiguration? {
        self.sessionReader?.configuration
    }

    private func makeBaseURL() throws -> URL {
        let baseURLConfiguration = self.configuration.baseURL ?? self.sessionConfiguration?.baseURL
        guard let baseURLRepresentation = baseURLConfiguration else {
            throw NetworkerError.path(.baseURLMissing)
        }

        guard let baseURL = URL(string: baseURLRepresentation) else {
            throw NetworkerError.path(.invalidBaseURL(baseURLRepresentation))
        }

        return baseURL
    }
}
