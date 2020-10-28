//
//  Result+Error.swift
//  
//
//  Created by RICHEZ Thibaut on 10/25/20.
//

import Foundation
@testable import Networker

extension Swift.Result {
    var error: Failure? {
        if case .failure(let error) = self {
            return error
        }

        return nil
    }
}
