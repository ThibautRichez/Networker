import Foundation

struct Networker {
    var session: URLSessionProtocol = URLSession.shared
    var configuration: NetworkerConfiguration = .init()
    var queues: NetworkerQueues = .init()
    var sessionReader: NetworkerSessionConfigurationReader? = NetworkerSessionConfigurationRepository()
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
        // not using appendingPathComponent because path may contain
        // non component information that will be formatted otherwise
        // (query items for exemple)
        // TODO:
        // Should check if it really bother URLSession that the url is
        // is formatted like '.../getPage%3Fnamed=home' and not '.../getPage?named=home'
        // -> Add concat strategy and test if needed
        guard let url = URL(string: baseURL.absoluteString + path) else {
            throw NetworkerError.path(.invalidRelativePath(path))
        }

        return url
    }

    func makeURLRequest(for type: URLRequestType,
                        cachePolicy: NetworkerCachePolicy? = .partial,
                        with url: URL) -> URLRequest {
        var urlRequest = URLRequest(url: url, timeoutInterval: self.configuration.timeoutInterval)
        urlRequest.httpMethod = type.rawValue
        if let cachePolicy = cachePolicy {
            urlRequest.cachePolicy = .init(networkerPolicy: cachePolicy)
        }
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

        return self.appendingToken(in: baseURL)
    }

    private func appendingToken(in url: URL) -> URL {
        let configurationToken = self.configuration.token ?? self.sessionConfiguration?.token
        guard let token = configurationToken else {
            return url
        }

        return url
            .appendingPathComponent(token, isDirectory: true)
    }
}
