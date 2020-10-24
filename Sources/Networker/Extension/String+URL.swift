//
//  File.swift
//  
//
//  Created by RICHEZ Thibaut on 10/24/20.
//

import Foundation

extension String {
    var isAbsoluteURL: Bool {
        self.hasPrefix("https://") || self.hasPrefix("http://")
    }
}
