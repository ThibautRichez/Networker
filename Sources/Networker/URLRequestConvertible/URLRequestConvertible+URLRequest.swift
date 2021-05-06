//
//  File.swift
//  
//
//  Created by RICHEZ Thibaut on 5/6/21.
//

import Foundation

extension URLRequest: URLRequestConvertible {
    public func asURLRequest() throws -> URLRequest { self }
}
