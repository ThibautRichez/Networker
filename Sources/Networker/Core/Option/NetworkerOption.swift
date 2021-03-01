//
//  NetworkerOption.swift
//  
//
//  Created by RICHEZ Thibaut on 3/1/21.
//

import Foundation

public enum NetworkerOption {
    case cachePolicy(NetworkerCachePolicy)
    case headers([String: String])
}
