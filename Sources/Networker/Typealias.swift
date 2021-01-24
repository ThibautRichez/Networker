//
//  Typealias.swift
//  
//
//  Created by RICHEZ Thibaut on 10/25/20.
//

import Foundation

public typealias NetworkCancellableRequester = NetworkRequester & NetworkCancellable
public typealias NetworkCancellableUploader = NetworkUploader & NetworkCancellable
public typealias NetworkCancellableDownloader = NetworkDownloader & NetworkCancellable

public typealias NetworkerProtocol = NetworkRequester & NetworkUploader & NetworkDownloader & NetworkCancellable


public typealias NetworkDecodeCancellableRequester = NetworkDecodableRequester & NetworkCancellable
public typealias NetworkDecodeCancellableUploader = NetworkEncodableUploader & NetworkCancellable

public typealias NetworkerCodableProtocol = NetworkDecodableRequester & NetworkEncodableUploader & NetworkCancellable
