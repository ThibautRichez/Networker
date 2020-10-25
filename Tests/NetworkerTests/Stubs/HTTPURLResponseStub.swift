//
//  HTTPURLResponseStub.swift
//  
//
//  Created by RICHEZ Thibaut on 10/25/20.
//

import Foundation

final class HTTPURLResponseStub: HTTPURLResponse {
    private let _statusCode: Int
    private let _allHeaderFields: [AnyHashable : Any]

    override var allHeaderFields: [AnyHashable : Any] {
        self._allHeaderFields
    }

    override var statusCode: Int {
        self._statusCode
    }

    init(url: String,
         statusCode: Int,
         allHeaderFields: [AnyHashable : Any] = [:],
         mimeType: String? = nil) {
        self._statusCode = statusCode
        self._allHeaderFields = allHeaderFields
        super.init(
            url: URL(string: url)!,
            mimeType: mimeType,
            expectedContentLength: -1,
            textEncodingName: nil
        )
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
