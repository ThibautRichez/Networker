//
//  URLRequestConvertible.swift
//  
//
//  Created by RICHEZ Thibaut on 3/14/21.
//

import Foundation

// TODO: Add DOC
public protocol URLRequestConvertible {
    func asURLRequest() throws -> URLRequest
}

extension URLRequest: URLRequestConvertible {
    public func asURLRequest() throws -> URLRequest { self }
}
