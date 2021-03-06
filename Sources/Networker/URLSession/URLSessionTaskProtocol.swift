//
//  File.swift
//  
//
//  Created by RICHEZ Thibaut on 10/24/20.
//

import Foundation

public protocol URLSessionTaskProtocol {
    var taskIdentifier: Int { get }

    func resume()
    func cancel()
}

extension URLSessionTask: URLSessionTaskProtocol {}
