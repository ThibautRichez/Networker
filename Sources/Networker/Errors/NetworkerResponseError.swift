//
//  NetworkerResponseError.swift
//  
//
//  Created by RICHEZ Thibaut on 5/6/21.
//

import Foundation

public enum NetworkerResponseError: Error {
    case empty
    case emptyData(HTTPURLResponse)
    // Expect HTTPURLResponse -> http/https requests
    case invalid(URLResponse)
    case validator(NetworkerResponseValidatorError)
}

public enum NetworkerResponseValidatorError: Error {
    case statusCode(HTTPURLResponse)
    case invalidMimeType(HTTPURLResponse)
    case invalidHeaders(HTTPURLResponse)
    case invalidExpectedContentLength(HTTPURLResponse)
    case invalidSuggestedFilename(HTTPURLResponse)
    case invalidTextEncodingName(HTTPURLResponse)
    case invalidURL(HTTPURLResponse)
    case custom(Error?, HTTPURLResponse)
}
