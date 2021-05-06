//
//  DownloaderFileHandlerMock.swift
//  
//
//  Created by RICHEZ Thibaut on 11/1/20.
//

import Foundation

// Used to monitore the closure passed to handle the fileURL
// in Networker.download methods.
final class DownloaderFileHandlerMock {
    var handleFileCallCount = 0
    var handleFileArguments = [URL]()
    var didCallHandleFileCallCount: Bool {
        self.handleFileCallCount > 0
    }

    func handleFile(url: URL) {
        self.handleFileCallCount += 1
        self.handleFileArguments.append(url)
    }
}
