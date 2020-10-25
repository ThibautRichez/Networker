import Foundation

// 1 - set token -> append token to each non absolute url string passed
// 2 - set baseURL -> append baseURL to each non absolute url string passed

enum URLRequestType: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
}

enum MimeType: String {
    case json = "application/json"
    case text = "text/plain"
    case html = "text/html"
    case jpg = "image/jpeg"
    case png = "image/png"
}

struct NetworkerResult {
    var data: Data
    var statusCode: Int
    var headerFields: [AnyHashable : Any]
}

protocol NetworkConfigurable {
    mutating func setBaseURL(to url: String?)
    mutating func setToken(to token: String?)
}

protocol NetworkCancellable {
    func cancelTask(with identifier: Int, completion: (() -> Void)?)
    func cancelTasks(completion: (() -> Void)?)
}

protocol NetworkRequester: NetworkConfigurable {
    @discardableResult
    func request(path: String,
                 completion: @escaping (Result<NetworkerResult, NetworkerError>) -> Void) -> URLSessionTaskProtocol?
    @discardableResult
    func request(url: URL,
                 completion: @escaping (Result<NetworkerResult, NetworkerError>) -> Void) -> URLSessionTaskProtocol
    @discardableResult
    func request(urlRequest: URLRequest,
                 completion: @escaping (Result<NetworkerResult, NetworkerError>) -> Void) -> URLSessionTaskProtocol
}

protocol NetworkDecodableRequester: NetworkConfigurable {
    @discardableResult
    func request<T : Decodable>(type: T.Type,
                                decoder: JSONDecoder,
                                atPath path: String,
                                completion: @escaping (Result<T, NetworkerError>) -> Void) -> URLSessionTaskProtocol?
}

protocol NetworkUploader: NetworkConfigurable {}

protocol NetworkEncodableUploader: NetworkConfigurable {}

protocol NetworkDownloader: NetworkConfigurable {}

protocol NetworkDecodableDownloader: NetworkConfigurable {}

// cannot make typealias beacause they both conform to NetworkCancellable
protocol NetworkerProtocol: NetworkRequester, NetworkUploader, NetworkDownloader, NetworkCancellable {}
protocol NetworkerCodableProtocol: NetworkDecodableRequester, NetworkEncodableUploader, NetworkDecodableDownloader, NetworkCancellable {}

private extension OperationQueue {
    static func networker() -> OperationQueue {
        let queue = OperationQueue()
        queue.name = "networker.operations.default.queue"
        queue.maxConcurrentOperationCount = 1
        queue.qualityOfService = .userInitiated
        return queue
    }
}

struct NetworkerQueues {
    var operations: OperationQueue = .networker()
    var callback: DispatchQueue = .main
}

struct Networker {
    var session: URLSessionProtocol = URLSession.shared
    var configuration: NetworkerConfiguration = .init()
    var queues: NetworkerQueues = .init()
    var sessionReader: NetworkerSessionConfigurationReader? = NetworkerSessionConfigurationRepository.shared
    var acceptableMimeTypes: Set<MimeType> = [.json]
}

// MARK: - NetworkerProtocol

extension Networker: NetworkerProtocol {
    // MARK: NetworkConfigurable

    mutating func setBaseURL(to url: String?) {
        self.configuration.baseURL = url
    }

    mutating func setToken(to token: String?) {
        self.configuration.token = token
    }

    // MARK: NetworkRequester

    @discardableResult
    func request(path: String,
                 completion: @escaping (Result<NetworkerResult, NetworkerError>) -> Void) -> URLSessionTaskProtocol? {
        do {
            let requestURL = try self.makeURL(from: path)
            return self.request(url: requestURL, completion: completion)
        } catch let error as NetworkerError {
            self.queues.callback.async {
                completion(.failure(error))
            }
            return nil
        } catch {
            self.queues.callback.async {
                completion(.failure(.unknown(error)))
            }
            return nil
        }
    }

    @discardableResult
    func request(url: URL,
                 completion: @escaping (Result<NetworkerResult, NetworkerError>) -> Void) -> URLSessionTaskProtocol {
        let urlRequest = self.makeURLRequest(for: .get, with: url)
        return self.request(urlRequest: urlRequest, completion: completion)
    }

    @discardableResult
    func request(urlRequest: URLRequest,
                 completion: @escaping (Result<NetworkerResult, NetworkerError>) -> Void) -> URLSessionTaskProtocol {
        let task = self.session.request(with: urlRequest) { (data, response, error) in
            if let error = error {
                self.queues.callback.async {
                    completion(.failure(.remote(NetworkerRemoteError(error))))
                }
                return
            }

            do {
                let httpResponse = try self.getHTTPResponse(from: response)
                let result = try self.getResult(with: data, response: httpResponse)
                self.queues.callback.async {
                    completion(.success(result))
                }
            } catch let error as NetworkerError {
                self.queues.callback.async {
                    completion(.failure(error))
                }
            } catch {
                self.queues.callback.async {
                    completion(.failure(.unknown(error)))
                }
            }
        }

        self.queues.operations.addOperation {
            task.resume()
        }

        return task
    }

    // MARK: NetworkCancellable

    func cancelTask(with identifier: Int, completion: (() -> Void)?) {
        self.session.getTasks { (tasks) in
            let task = tasks.first { $0.taskIdentifier == identifier }
            task?.cancel()
            completion?()
        }
    }

    func cancelTasks(completion: (() -> Void)?) {
        self.session.getTasks { (tasks) in
            tasks.forEach { $0.cancel() }
            completion?()
        }
    }
}

// MARK: - NetworkerCodableProtocol

extension Networker: NetworkerCodableProtocol {
    func request<T: Decodable>(type: T.Type,
                               decoder: JSONDecoder,
                               atPath path: String,
                               completion: @escaping (Result<T, NetworkerError>) -> Void) -> URLSessionTaskProtocol? {
        self.request(path: path) { result in
            let decodableResult = self.convertResult(result, to: type, with: decoder)
            // already in callbackQueue.
            completion(decodableResult)
        }
    }

    @discardableResult
    func request<T: Decodable>(type: T.Type,
                               decoder: JSONDecoder,
                               url: URL,
                               completion: @escaping (Result<T, NetworkerError>) -> Void) -> URLSessionTaskProtocol {
        self.request(url: url) { result in
            let decodableResult = self.convertResult(result, to: type, with: decoder)
            // already in callbackQueue.
            completion(decodableResult)
        }
    }


    @discardableResult
    func request<T: Decodable>(type: T.Type,
                               decoder: JSONDecoder,
                               urlRequest: URLRequest,
                               completion: @escaping (Result<T, NetworkerError>) -> Void) -> URLSessionTaskProtocol {
        self.request(urlRequest: urlRequest) { result in
            let decodableResult = self.convertResult(result, to: type, with: decoder)
            // already in callbackQueue.
            completion(decodableResult)
        }
    }
}

private extension Networker {
    func decode<T: Decodable>(type: T.Type,
                              from result: NetworkerResult,
                              decoder: JSONDecoder) -> Result<T, NetworkerError> {
        do {
            let model = try decoder.decode(T.self, from: result.data)
            return .success(model)
        } catch {
            return .failure(.decoder(error))
        }

    }

    func convertResult<T: Decodable>(_ result: Result<NetworkerResult, NetworkerError>,
                                     to type: T.Type,
                                     with decoder: JSONDecoder) -> Result<T, NetworkerError> {
        switch result {
        case .success(let networkResult):
            return self.decode(type: type, from: networkResult, decoder: decoder)
        case .failure(let error):
            return .failure(error)
        }
    }
}


private extension Networker {
    var sessionConfiguration: NetworkerSessionConfiguration? {
        self.sessionReader?.configuration
    }

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

    func makeBaseURL() throws -> URL {
        let baseURLConfiguration = self.configuration.baseURL ?? self.sessionConfiguration?.baseURL
        guard let baseURLRepresentation = baseURLConfiguration else {
            throw NetworkerError.path(.baseURLMissing)
        }

        guard let baseURL = URL(string: baseURLRepresentation) else {
            throw NetworkerError.path(.invalidBaseURL(baseURLRepresentation))
        }

        return baseURL
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

    func getResult(with data: Data?, response: HTTPURLResponse) throws -> NetworkerResult {
        guard let data = data else { throw NetworkerError.response(.empty) }

        return .init(
            data: data,
            statusCode: response.statusCode,
            headerFields: response.allHeaderFields
        )
    }
}
