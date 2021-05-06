//
//  NetworkerError.swift
//  
//
//  Created by RICHEZ Thibaut on 10/24/20.
//

import Foundation

public enum NetworkerError: Error {
    case invalidURL(URLConvertible)
    case remote(NetworkerRemoteError)
    case response(NetworkerResponseError)
    case noData
    case download(NetworkerDownloadError)
    case decoder(Error)
    case encoder(Error)
    case unknown(Error)
}
