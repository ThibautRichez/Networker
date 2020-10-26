//
//  File.swift
//  
//
//  Created by RICHEZ Thibaut on 10/26/20.
//

import Foundation

extension UserDefaults {
    static func networker() -> UserDefaults {
        UserDefaults(suiteName: "networker.session.configuration") ?? .standard
    }
}
