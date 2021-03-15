//
//  StringInterpolation+Optional.swift
//  
//
//  Created by RICHEZ Thibaut on 10/25/20.
//

import Foundation

extension String.StringInterpolation {

    /// Prints `Optional` values by only interpolating it if the value is set. `nil` is used as a fallback value to provide a clear output.
    mutating func appendInterpolation<T>(_ value: T?) {
        value != nil ? appendInterpolation(value!) : appendLiteral("nil")
    }
}
