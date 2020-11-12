//
//  File.swift
//  
//
//  Created by RICHEZ Thibaut on 10/25/20.
//

import Foundation

enum MimeType {
    case json
    case text
    case html
    case jpg
    case png
    case other(String)
}

extension MimeType: RawRepresentable {
    init?(rawValue: String) {
        if let value = RawRepresentableCase(rawValue: rawValue) {
            self = value.type
        } else {
            self = .other(rawValue)
        }
    }

    var rawValue: String {
        switch self {
        case .json:
            return RawRepresentableCase.json.rawValue
        case .text:
            return RawRepresentableCase.text.rawValue
        case .html:
            return RawRepresentableCase.html.rawValue
        case .jpg:
            return RawRepresentableCase.jpg.rawValue
        case .png:
            return RawRepresentableCase.png.rawValue
        case .other(let value):
            return value
        }
    }
}

extension MimeType: Hashable {}

private extension MimeType {
    enum RawRepresentableCase: String {
        case json = "application/json"
        case text = "text/plain"
        case html = "text/html"
        case jpg = "image/jpeg"
        case png = "image/png"

        var type: MimeType {
            switch self {
            case .json:
                return .json
            case .text:
                return .text
            case .html:
                return .html
            case .jpg:
                return .jpg
            case .png:
                return .png
            }
        }
    }
}
