//
//  Networker+Access.swift
//  
//
//  Created by RICHEZ Thibaut on 10/25/20.
//

import Foundation
@testable import Networker

// MARK: - Request

extension Networker {
    func requestError(path: String,
                      completion: @escaping (NetworkerError?) -> Void) -> URLSessionTaskMock? {
        self.request(path: path) { (result) in
            if case .failure(let sutError) = result {
                completion(sutError)
                return
            }

            completion(nil)
        } as? URLSessionTaskMock
    }

    func requestSuccess(path: String,
                        completion: @escaping (NetworkRequesterResult?) -> Void) -> URLSessionTaskMock? {
        self.request(path: path) { (result) in
            completion(try? result.get())
        } as? URLSessionTaskMock
    }
}

// MARK: - Upload

extension Networker {
    func uploadError(path: String,
                     type: NetworkUploaderType = .post,
                     data: Data?,
                     completion: @escaping (NetworkerError?) -> Void) -> URLSessionTaskProtocol? {
        self.upload(path: path, type: type, data: data) { (result) in
            if case .failure(let sutError) = result {
                completion(sutError)
                return
            }

            completion(nil)
        } as? URLSessionTaskMock
    }

    func uploadSuccess(path: String,
                       type: NetworkUploaderType = .post,
                       data: Data?,
                       completion: @escaping (NetworkUploaderResult?) -> Void) -> URLSessionTaskProtocol? {
        self.upload(path: path, type: type, data: data) { (result) in
            completion(try? result.get())
        } as? URLSessionTaskMock
    }
}
