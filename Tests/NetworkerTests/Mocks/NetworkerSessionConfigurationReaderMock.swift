//
//  NetworkerSessionConfigurationReaderMock.swift
//  
//
//  Created by RICHEZ Thibaut on 10/25/20.
//

import Foundation
@testable import Networker

final class NetworkerSessionConfigurationReaderMock: NetworkerSessionConfigurationReader {
    var configurationResult: (() -> NetworkerSessionConfiguration)?

    var configuration: NetworkerSessionConfiguration {
        self.configurationResult?() ?? .init()
    }
}
