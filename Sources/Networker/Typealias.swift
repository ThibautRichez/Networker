//
//  Typealias.swift
//  
//
//  Created by RICHEZ Thibaut on 10/25/20.
//

import Foundation

typealias NetworkCancellableRequester = NetworkRequester & NetworkCancellable
typealias NetworkCancellableUploader = NetworkUploader & NetworkCancellable
typealias NetworkCancellableDownloader = NetworkDownloader & NetworkCancellable

typealias NetworkerProtocol = NetworkRequester & NetworkUploader & NetworkDownloader & NetworkCancellable


typealias NetworkDecodeCancellableRequester = NetworkDecodableRequester & NetworkCancellable
typealias NetworkDecodeCancellableUploader = NetworkEncodableUploader & NetworkCancellable
typealias NetworkDecodeCancellableDownloader = NetworkDecodableDownloader & NetworkCancellable

typealias NetworkerCodableProtocol = NetworkDecodableRequester & NetworkEncodableUploader & NetworkDecodableDownloader & NetworkCancellable
