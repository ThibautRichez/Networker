//
//  NetworkerURLStringConcatener.swift
//  
//
//  Created by RICHEZ Thibaut on 10/31/20.
//

import Foundation

public protocol URLStringConcatener {
    func concat(_ value: String, with otherString: String) -> String
}

public struct NetworkerURLStringConcatener: URLStringConcatener {
    public init() {}

    public func concat(_ value: String, with otherString: String) -> String {
        var result = value
        switch (value.hasSuffix("/"), otherString.hasPrefix("/")) {
        case (true, true):
            result.append(String(otherString.dropFirst()))

        case (true, false), (false, true):
            result.append(otherString)

        case (false, false):
            result.append("/\(otherString)")
        }

        return result
    }
}
