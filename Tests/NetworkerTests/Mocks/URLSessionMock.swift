//
//  URLSessionMock.swift
//  
//
//  Created by RICHEZ Thibaut on 10/25/20.
//

import Foundation
@testable import Networker

final class URLSessionTaskMock: URLSessionTaskProtocol {
    var taskIdentifier: Int

    var resumeCallCount = 0
    var didCallResume: Bool {
        self.resumeCallCount > 0
    }

    var cancelCallCount = 0
    var didCallCancel: Bool {
        self.cancelCallCount > 0
    }

    init(taskIdentifier: Int = 1) {
        self.taskIdentifier = taskIdentifier
    }

    func resume() {
        self.resumeCallCount += 1
    }

    func cancel() {
        self.cancelCallCount += 1
    }
}

final class URLSessionMock: URLSessionProtocol {
    var requestCallCount = 0
    var requestArguments = [URLRequest]()
    var requestCompletion: ((_ completionHandler:  @escaping (Data?, URLResponse?, Error?) -> Void) -> Void)?
    var requestResult: (() -> URLSessionTaskProtocol)?
    var didCallRequest: Bool {
        self.requestCallCount > 0
    }

    var uploadCallCount = 0
    var uploadArguments = [(request: URLRequest, data: Data?)]()
    var uploadCompletion: ((_ completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> Void)?
    var uploadResult: (() -> URLSessionTaskProtocol)?
    var didCallUpload: Bool {
        self.uploadCallCount > 0
    }

    var downloadCallCount = 0
    var downloadArguments = [URLRequest]()
    var downloadCompletion: ((_ completionHandler: @escaping (URL?, URLResponse?, Error?) -> Void) -> Void)?
    var downloadResult: (() -> URLSessionTaskProtocol)?
    var didCallDownload: Bool {
        self.downloadCallCount > 0
    }

    var getTasksCallCount = 0
    var getTasksCompletion: ((_ completionHandler: @escaping ([URLSessionTaskProtocol]) -> Void) -> Void)?
    var didCallGetTasks: Bool {
        self.getTasksCallCount > 0
    }

    func request(with request: URLRequest,
                 completion: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionTaskProtocol {
        self.requestCallCount += 1
        self.requestArguments.append(request)
        self.requestCompletion?(completion)
        return self.requestResult?() ?? URLSessionTaskMock()
    }

    func upload(with request: URLRequest,
                from bodyData: Data?, completion: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionTaskProtocol {
        self.uploadCallCount += 1
        self.uploadArguments.append((request, bodyData))
        self.uploadCompletion?(completion)
        return self.uploadResult?() ?? URLSessionTaskMock()
    }

    func download(with request: URLRequest,
                  completion: @escaping (URL?, URLResponse?, Error?) -> Void) -> URLSessionTaskProtocol {
        self.downloadCallCount += 1
        self.downloadArguments.append(request)
        self.downloadCompletion?(completion)
        return self.downloadResult?() ?? URLSessionTaskMock()
    }

    func getTasks(completion: @escaping ([URLSessionTaskProtocol]) -> Void) {
        self.getTasksCallCount += 1
        self.getTasksCompletion?(completion)
    }
}
