//
//  Typealias.swift
//  
//
//  Created by RICHEZ Thibaut on 10/25/20.
//

import Foundation

// MARK: - Requester

public typealias NetworkCancellableRequester = NetworkRequester & NetworkCancellable
public typealias NetworkDecodeCancellableRequester = NetworkCancellableRequester & NetworkDecodableRequester

// MARK: - Uploader

public typealias NetworkCancellableUploader = NetworkUploader & NetworkCancellable
public typealias NetworkDecodeCancellableUploader = NetworkCancellableUploader & NetworkEncodableUploader

// MARK: - Downloader

public typealias NetworkCancellableDownloader = NetworkDownloader & NetworkCancellable

// MARK: - All

public typealias NetworkerProtocol = NetworkDecodeCancellableRequester & NetworkDecodeCancellableUploader & NetworkCancellableDownloader
