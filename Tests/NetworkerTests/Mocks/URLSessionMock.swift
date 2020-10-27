//
//  URLSessionMock.swift
//  
//
//  Created by RICHEZ Thibaut on 10/25/20.
//

import Foundation
@testable import Networker

final class URLSessionMock: URLSessionProtocol {
    var requestCallCount = 0
    var requestArguments = [URLRequest]()
    var requestResultCompletion: ((_ completionHandler:  @escaping (Data?, URLResponse?, Error?) -> Void) -> Void)?
    var requestResult: (() -> URLSessionTaskMock)?
    var didCallRequest: Bool {
        self.requestCallCount > 0
    }

    var uploadCallCount = 0
    var uploadArguments = [(request: URLRequest, data: Data?)]()
    var uploadResultCompletion: ((_ completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> Void)?
    var uploadResult: (() -> URLSessionTaskMock)?
    var didCallUpload: Bool {
        self.uploadCallCount > 0
    }

    var downloadCallCount = 0
    var downloadArguments = [URLRequest]()
    var downloadResultCompletion: ((_ completionHandler: @escaping (URL?, URLResponse?, Error?) -> Void) -> Void)?
    var downloadResult: (() -> URLSessionTaskMock)?
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

        let task = self.requestResult?() ?? URLSessionTaskMock()
        task.requestCompletion = completion
        task.resultCompletion = self.requestResultCompletion
        return task
    }

    func upload(with request: URLRequest,
                from bodyData: Data?,
                completion: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionTaskProtocol {
        self.uploadCallCount += 1
        self.uploadArguments.append((request, bodyData))

        let task = self.uploadResult?() ?? URLSessionTaskMock()
        task.requestCompletion = completion
        task.resultCompletion = self.uploadResultCompletion
        return task
    }

    func download(with request: URLRequest,
                  completion: @escaping (URL?, URLResponse?, Error?) -> Void) -> URLSessionTaskProtocol {
        self.downloadCallCount += 1
        self.downloadArguments.append(request)

        let task = self.downloadResult?() ?? URLSessionTaskMock()
        task.downloadCompletion = completion
        task.downloadResultCompletion = self.downloadResultCompletion
        return task
    }

    func getTasks(completion: @escaping ([URLSessionTaskProtocol]) -> Void) {
        self.getTasksCallCount += 1
        self.getTasksCompletion?(completion)
    }
}

// Handles calling the session completions when `resume` if called
// to mock default behavior.
final class URLSessionTaskMock: URLSessionTaskProtocol {
    let taskIdentifier: Int
    var requestCompletion: ((Data?, URLResponse?, Error?) -> Void)?
    var resultCompletion: ((_ completionHandler:  @escaping (Data?, URLResponse?, Error?) -> Void) -> Void)?

    var downloadCompletion: ((URL?, URLResponse?, Error?) -> Void)?
    var downloadResultCompletion: ((_ completionHandler:  @escaping (URL?, URLResponse?, Error?) -> Void) -> Void)?


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

        if let requestCompletion = self.requestCompletion {
            self.resultCompletion?(requestCompletion)
        }

        if let downloadCompletion = self.downloadCompletion {
            self.downloadResultCompletion?(downloadCompletion)
        }
    }

    func cancel() {
        self.cancelCallCount += 1

        let cancelError = NSError(
            domain: "\(String(describing: self)) has cancel the test",
            code: -100,
            userInfo: nil
        )
        self.requestCompletion?(nil, nil, cancelError)
    }
}
