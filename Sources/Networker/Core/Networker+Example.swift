//
//  File.swift
//  
//
//  Created by RICHEZ Thibaut on 10/26/20.
//

import Foundation

// Example
//fileprivate extension Networker {
//    static func defaults() -> Self {
//        .init(configuration: .init(baseURL: "https://app-baseURL.com"))
//    }
//
//    static func custom() -> Self {
//        let sessionConfiguration = URLSessionConfiguration.default
//        sessionConfiguration.requestCachePolicy = .useProtocolCachePolicy
//        let session = URLSession(configuration: sessionConfiguration)
//
//        let configuration = NetworkerConfiguration(
//            baseURL: "https://app-baseURL.com",
//            token: "1234567YGVFGHJJUYTRYUIU765RG",
//            timeoutInterval: 120
//        )
//
//        let operationQueue = OperationQueue()
//        operationQueue.name = "networker.operations.utility.queue"
//        operationQueue.maxConcurrentOperationCount = 1
//        operationQueue.qualityOfService = .utility
//        let queues = NetworkerQueues(operations: operationQueue, callback: .main)
//
//        return .init(
//            session: session, configuration: configuration,
//            queues: queues, acceptableMimeTypes: Set(arrayLiteral: .jpg, .json)
//        )
//    }
//}
//
//fileprivate struct ViewModel {
//    var networker: Networker = .custom()
//
//    func fetch() {
//        self.networker.request(
//            "https://api.com",
//            method: .get,
//            requestModifiers: [
//                .cachePolicy(.reloadIgnoringLocalCache),
//                .headers(["content-type": "application/json"]),
//                .serviceType(.responsiveData),
//                .authorizations([.cellularAccess, .cookies]),
//                .httpBody(Data()),
//                .bodyStream(InputStream(url: URL(string: "")!)),
//                .mainDocumentURL(URL(string: "")!),
//                .custom({ $0.timeoutInterval = 5 })
//            ]) { (result) in
//            switch result {
//            case .success(let networkerResult):
//                print(networkerResult)
//            case .failure(let error):
//                print(error)
//            }
//        }
//    }
//}
