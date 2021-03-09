//
//  URLRequest+NetworkerRequestModifier.swift
//  
//
//  Created by RICHEZ Thibaut on 3/7/21.
//

import Foundation

extension URLRequest {
    mutating func apply(modifiers: [NetworkerRequestModifier]) {
        modifiers.forEach { option in
            switch option {
            case .cachePolicy(let policy):
                self.cachePolicy = .init(networkerPolicy: policy)
            case .headers(let headers, let shouldOverride):
                self.add(headers: headers, override: shouldOverride)
            case .serviceType(let type):
                self.networkServiceType = type
            case .authorizations(let authorizations):
                self.set(authorizations: authorizations)
            case .httpBody(let httpBody):
                self.httpBody = httpBody
            case .bodyStream(let bodyStream):
                self.httpBodyStream = bodyStream
            case .mainDocumentURL(let mainDocumentURL):
                self.mainDocumentURL = mainDocumentURL
            case .custom(let modifier):
                modifier(&self)
            }
        }
    }
}

private extension URLRequest {
    mutating func add(headers: [String: String]?, override: Bool) {
        headers?.forEach { key, value in
            if override {
                self.setValue(value, forHTTPHeaderField: key)
            } else {
                self.addValue(value, forHTTPHeaderField: key)
            }
        }
    }

    mutating func set(authorizations: NetworkerRequestAuthorizations) {
        self.allowsCellularAccess = authorizations.contains(.cellularAccess)
        self.httpShouldHandleCookies = authorizations.contains(.cookies)
        self.httpShouldUsePipelining = authorizations.contains(.pipelining)

        if #available(iOS 13.0, OSX 10.15, *) {
            self.allowsExpensiveNetworkAccess = authorizations.contains(.expensiveNetworkAccess)
            self.allowsConstrainedNetworkAccess = authorizations.contains(.constrainedNetworkAccess)
        }
    }
}
