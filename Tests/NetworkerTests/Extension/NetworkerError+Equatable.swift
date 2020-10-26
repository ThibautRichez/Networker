//
//  NetworkerError+Equatable.swift
//  
//
//  Created by RICHEZ Thibaut on 10/26/20.
//

import Foundation
@testable import Networker

extension NetworkerError: Equatable {
    public static func == (lhs: NetworkerError, rhs: NetworkerError) -> Bool {
        String(reflecting: lhs) == String(reflecting: rhs)
    }
}
