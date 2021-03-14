//
//  File.swift
//  
//
//  Created by RICHEZ Thibaut on 10/26/20.
//

import Foundation

// Example
fileprivate extension URLSession {
    static var `default`: URLSession = {
        let sessionConfiguration = URLSessionConfiguration.default
        sessionConfiguration.requestCachePolicy = .useProtocolCachePolicy
        // https://developer.apple.com/documentation/foundation/urlsessionconfiguration/1411532-httpadditionalheaders
        sessionConfiguration.httpAdditionalHeaders = ["User-Agent": "..."]
        return URLSession(configuration: sessionConfiguration)
    }()
}

fileprivate extension NetworkerConfiguration {
    static func make(baseURL: String) -> NetworkerConfiguration {
        return NetworkerConfiguration(
            baseURL: baseURL,
            requestModifiers: [
                .cachePolicy(.useProtocolCachePolicy),
                .timeoutInterval(100)
            ],
            responseValidators: [
                .statusCode({ code in (200..<300).contains(code) })
            ]
        )
    }
}

fileprivate extension Networker {
    static func make(with baseURL: String, token: String) -> Self {
        let operationQueue = OperationQueue()
        operationQueue.name = "networker.operations.utility.queue"
        operationQueue.maxConcurrentOperationCount = 1
        operationQueue.qualityOfService = .userInteractive
        let queues = NetworkerQueues(operation: operationQueue, callback: .main)

        return .init(
            session: URLSession.default,
            configuration: .make(baseURL: "\(baseURL)/\(token)"),
            queues: queues
        )
    }
}

fileprivate struct ViewModel {
    var networker: Networker = .make(with: "https://api.com", token: "")

    func fetch() {
        self.networker.request(
            "getPage?pagename=home"/*.asURL(relativeTo: "https://api.com")*/,
            method: .get,
            requestModifiers: [
                .cachePolicy(.returnCacheDataElseLoad),
                .headers(["Content-Type": "application/json"]),
                .serviceType(.responsiveData),
                .authorizations([.cellularAccess, .cookies]),
                .httpBody(Data()),
                .bodyStream(InputStream(url: URL(string: "")!)),
                .mainDocumentURL(URL(string: "")!),
                .custom({ $0.timeoutInterval = 5 })
            ]) { (result) in
            switch result {
            case .success(let networkerResult):
                print(networkerResult)
            case .failure(let error):
                print(error)
            }
        }
    }
}
