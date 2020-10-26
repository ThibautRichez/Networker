//
//  NetworkerCachePolicy.swift
//  
//
//  Created by RICHEZ Thibaut on 10/26/20.
//

import Foundation

enum NetworkerCachePolicy {
    /// Partial cache with default settings.
    case partial

    /// The URL load should be loaded only from the originating source.
    case reloadIgnoringLocalCache

    /// Exist in the documentation but doesn't seem
    /// to be implemented by the system.
    /// This option should be avoided.
    case reloadIgnoringLocalAndRemoteCache

    /// Exist in the documentation but doesn't seem
    /// to be implemented by the system.
    /// This option should be avoided.
    case reloadRevalidatingCache

    /// Use existing cache data, regardless or age or expiration date,
    /// loading from originating source only if there is no cached data.
    case returnCacheElseLoad

    /// Use existing cache data, regardless or age or expiration date,
    /// and fail if no cached data is available.
    case returnCacheDontLoad
}

extension URLRequest.CachePolicy {
    init(networkerPolicy: NetworkerCachePolicy) {
        switch networkerPolicy {
        case .partial:
            self = .useProtocolCachePolicy
        case .reloadIgnoringLocalCache:
            self = .reloadIgnoringLocalCacheData
        case .reloadIgnoringLocalAndRemoteCache:
            self = .reloadIgnoringLocalAndRemoteCacheData
        case .reloadRevalidatingCache:
            self = .reloadRevalidatingCacheData
        case .returnCacheElseLoad:
            self = .returnCacheDataElseLoad
        case .returnCacheDontLoad:
            self = .returnCacheDataDontLoad
        }
    }
}
