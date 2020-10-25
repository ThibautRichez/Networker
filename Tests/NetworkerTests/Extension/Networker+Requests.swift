//
//  File.swift
//  
//
//  Created by RICHEZ Thibaut on 10/25/20.
//

import Foundation
@testable import Networker

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
