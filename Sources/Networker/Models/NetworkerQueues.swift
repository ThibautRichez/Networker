//
//  File.swift
//  
//
//  Created by RICHEZ Thibaut on 10/25/20.
//

import Foundation

struct NetworkerQueues {
    var operations: OperationQueue = .networker()
    var callback: DispatchQueue = .main
}
