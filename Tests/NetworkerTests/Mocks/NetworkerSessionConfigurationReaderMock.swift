//
//  NetworkerSessionConfigurationReaderMock.swift
//  
//
//  Created by RICHEZ Thibaut on 10/25/20.
//

import Foundation
@testable import Networker

struct NetworkerSessionConfigurationReaderMock: NetworkerSessionConfigurationReader {
    var configuration: NetworkerSessionConfiguration = .init()
}
