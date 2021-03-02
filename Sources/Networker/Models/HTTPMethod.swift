//
//  HTTPMethod.swift
//  
//
//  Created by RICHEZ Thibaut on 10/25/20.
//

import Foundation

/// Type representing HTTP methods. Raw `String` value is stored and
/// compared case-sensitively.
/// See https://github.com/Alamofire/Alamofire/blob/master/Source/HTTPMethod.swift
///
/// - Note: You can extend the type to add your custom values
/// `extension HTTPMethod { static let custom = HTTPMethod(rawValue: "CUSTOM") }`
public struct HTTPMethod: RawRepresentable, Equatable, Hashable {
    public static let connect = HTTPMethod(rawValue: "CONNECT")
    public static let delete = HTTPMethod(rawValue: "DELETE")
    public static let get = HTTPMethod(rawValue: "GET")
    public static let head = HTTPMethod(rawValue: "HEAD")
    public static let options = HTTPMethod(rawValue: "OPTIONS")
    public static let patch = HTTPMethod(rawValue: "PATCH")
    public static let post = HTTPMethod(rawValue: "POST")
    public static let put = HTTPMethod(rawValue: "PUT")
    public static let trace = HTTPMethod(rawValue: "TRACE")

    public let rawValue: String

    public init(rawValue: String) {
        self.rawValue = rawValue
    }
}
