//
//  URLRequest+NetworkerRequestModifierTests.swift
//  
//
//  Created by RICHEZ Thibaut on 3/15/21.
//

import Foundation
import XCTest
@testable import Networker

// TODO: add timeInterval
final class URLRequestModifierTests: XCTestCase {
    private var request: URLRequest!

    override func setUp() {
        super.setUp()
        self.request = URLRequest(url: URL(string: "https://test.com")!)
    }

    override func tearDown() {
        super.tearDown()
        self.request = nil
    }

    // MARK: - Timeout Interval

    func test_GivenTimeoutIntervalModifier_WhenAppliedToRequest_ThenRequestTimeoutIntervalShouldMatch() {
        // GIVEN
        let timeoutInterval: TimeInterval = 12
        let modifier: NetworkerRequestModifier = .timeoutInterval(timeoutInterval)
        // WHEN
        self.request.apply(modifiers: [modifier])
        // THEN
        XCTAssertEqual(self.request.timeoutInterval, timeoutInterval)
    }

    // MARK: - Cache Policy

    func test_GivenAnyCachePolicyModifier_WhenAppliedToRequest_ThenRequestCachePolicyShouldMatch() {
        [
            URLRequest.CachePolicy.useProtocolCachePolicy,
            .reloadIgnoringLocalCacheData,
            .reloadIgnoringLocalAndRemoteCacheData,
            .reloadRevalidatingCacheData,
            .returnCacheDataElseLoad,
            .returnCacheDataDontLoad

        ].forEach { cachePolicy in
            // GIVEN
            let modifier: NetworkerRequestModifier = .cachePolicy(cachePolicy)
            // WHEN
            self.request.apply(modifiers: [modifier])
            // THEN
            XCTAssertEqual(self.request.cachePolicy, cachePolicy)
        }
    }

    // MARK: - Headers

    func test_GivenRequestWithContentTypeAndHeadersModifierWithContentTypeAndNoOverride_WhenAppliedToRequest_ThenRequestContentTypeShouldContainsBothValues() {
        // GIVEN
        let requestContentType = "application/json"
        self.request.addValue(requestContentType, forHTTPHeaderField: "Content-Type")

        let modifierContentType = "application/javascript"
        let modifier: NetworkerRequestModifier = .headers(["Content-Type": modifierContentType], override: false)
        // WHEN
        self.request.apply(modifiers: [modifier])
        // THEN
        XCTAssertEqual(self.request.allHTTPHeaderFields, ["Content-Type": [requestContentType, modifierContentType].joined(separator: ",")])
    }

    func test_GivenRequestWithContentTypeAndHeadersModifierWithContentTypeAndOverride_WhenAppliedToRequest_ThenRequestContentTypeShouldBeTheModifierValue() {
        // GIVEN
        let requestContentType = "application/json"
        self.request.addValue(requestContentType, forHTTPHeaderField: "Content-Type")

        let modifierContentType = "application/javascript"
        let modifier: NetworkerRequestModifier = .headers(["Content-Type": modifierContentType], override: true)
        // WHEN
        self.request.apply(modifiers: [modifier])
        // THEN
        XCTAssertEqual(self.request.allHTTPHeaderFields, ["Content-Type": modifierContentType])
    }

    // MARK: - ServiceType

    func test_GivenAnyServiceTypeModifier_WhenAppliedToRequest_ThenRequestNetworkServiceTypeShouldMatch() {
        [
            URLRequest.NetworkServiceType.default,
            .video,
            .background,
            .voice,
            .callSignaling,
            .responsiveData,
            .avStreaming,
            .responsiveAV
        ].forEach { serviceType in
            // GIVEN
            let modifier: NetworkerRequestModifier = .serviceType(serviceType)
            // WHEN
            self.request.apply(modifiers: [modifier])
            // THEN
            XCTAssertEqual(self.request.networkServiceType, serviceType)
        }
    }

    // MARK: - Authorizations

    func test_GivenAllAuthorizationsModifier_WhenAppliedToRequest_ThenRequestShouldHaveAllAuthorizations() {
        // GIVEN
        let modifier: NetworkerRequestModifier = .authorizations(.all)
        // WHEN
        self.request.apply(modifiers: [modifier])
        // THEN
        XCTAssertTrue(self.request.allowsCellularAccess)
        XCTAssertTrue(self.request.httpShouldHandleCookies)
        XCTAssertTrue(self.request.httpShouldUsePipelining)
        if #available(macOS 10.15, iOS 13.0, watchOS 6.0, tvOS 13.0, *) {
            XCTAssertTrue(self.request.allowsExpensiveNetworkAccess)
            XCTAssertTrue(self.request.allowsConstrainedNetworkAccess)
        }
    }

    func test_GivenCellularAccessAuthorizationModifier_WhenAppliedToRequest_ThenRequestShouldOnlyHaveCellularAccessAuthorization() {
        // GIVEN
        let modifier: NetworkerRequestModifier = .authorizations(.cellularAccess)
        // WHEN
        self.request.apply(modifiers: [modifier])
        // THEN
        XCTAssertTrue(self.request.allowsCellularAccess)
        XCTAssertFalse(self.request.httpShouldHandleCookies)
        XCTAssertFalse(self.request.httpShouldUsePipelining)
        if #available(macOS 10.15, iOS 13.0, watchOS 6.0, tvOS 13.0, *) {
            XCTAssertFalse(self.request.allowsExpensiveNetworkAccess)
            XCTAssertFalse(self.request.allowsConstrainedNetworkAccess)
        }
    }

    func test_GivenExpensiveNetworkAccessAuthorizationModifier_WhenAppliedToRequest_ThenRequestShouldOnlyHaveExpensiveNetworkAccesAuthorization() {
        // GIVEN
        let modifier: NetworkerRequestModifier = .authorizations(.expensiveNetworkAccess)
        // WHEN
        self.request.apply(modifiers: [modifier])
        // THEN
        XCTAssertFalse(self.request.allowsCellularAccess)
        XCTAssertFalse(self.request.httpShouldHandleCookies)
        XCTAssertFalse(self.request.httpShouldUsePipelining)
        if #available(macOS 10.15, iOS 13.0, watchOS 6.0, tvOS 13.0, *) {
            XCTAssertTrue(self.request.allowsExpensiveNetworkAccess)
            XCTAssertFalse(self.request.allowsConstrainedNetworkAccess)
        }
    }

    func test_GivenConstrainedNetworkAccessAuthorizationModifier_WhenAppliedToRequest_ThenRequestShouldOnlyHaveConstrainedNetworkAccessAuthorization() {
        // GIVEN
        let modifier: NetworkerRequestModifier = .authorizations(.constrainedNetworkAccess)
        // WHEN
        self.request.apply(modifiers: [modifier])
        // THEN
        XCTAssertFalse(self.request.allowsCellularAccess)
        XCTAssertFalse(self.request.httpShouldHandleCookies)
        XCTAssertFalse(self.request.httpShouldUsePipelining)
        if #available(macOS 10.15, iOS 13.0, watchOS 6.0, tvOS 13.0, *) {
            XCTAssertFalse(self.request.allowsExpensiveNetworkAccess)
            XCTAssertTrue(self.request.allowsConstrainedNetworkAccess)
        }
    }

    func test_GivenCookiesAuthorizationModifier_WhenAppliedToRequest_ThenRequestShouldOnlyHaveCookiesAuthorization() {
        // GIVEN
        let modifier: NetworkerRequestModifier = .authorizations(.cookies)
        // WHEN
        self.request.apply(modifiers: [modifier])
        // THEN
        XCTAssertFalse(self.request.allowsCellularAccess)
        XCTAssertTrue(self.request.httpShouldHandleCookies)
        XCTAssertFalse(self.request.httpShouldUsePipelining)
        if #available(macOS 10.15, iOS 13.0, watchOS 6.0, tvOS 13.0, *) {
            XCTAssertFalse(self.request.allowsExpensiveNetworkAccess)
            XCTAssertFalse(self.request.allowsConstrainedNetworkAccess)
        }
    }

    func test_GivenPipeliningAuthorizationModifier_WhenAppliedToRequest_ThenRequestShouldOnlyHavePipeliningAuthorization() {
        // GIVEN
        let modifier: NetworkerRequestModifier = .authorizations(.pipelining)
        // WHEN
        self.request.apply(modifiers: [modifier])
        // THEN
        XCTAssertFalse(self.request.allowsCellularAccess)
        XCTAssertFalse(self.request.httpShouldHandleCookies)
        XCTAssertTrue(self.request.httpShouldUsePipelining)
        if #available(macOS 10.15, iOS 13.0, watchOS 6.0, tvOS 13.0, *) {
            XCTAssertFalse(self.request.allowsExpensiveNetworkAccess)
            XCTAssertFalse(self.request.allowsConstrainedNetworkAccess)
        }
    }

    // MARK: - HttpBody

    func test_GivenHttpBodyModifier_WhenAppliedToRequest_ThenRequestHttpBodyShouldMatch() {
        // GIVEN
        let modifierBodyData = "http body".data(using: .utf8)
        let modifier: NetworkerRequestModifier = .httpBody(modifierBodyData)
        // WHEN
        self.request.apply(modifiers: [modifier])
        // THEN
        XCTAssertEqual(self.request.httpBody, modifierBodyData)
    }

    // MARK: - BodyStream

    func test_GivenBodyStreamModifier_WhenAppliedToRequest_ThenRequestBodyStreamShouldMatch() {
        // GIVEN
        let modifierBodyStream = InputStream(data: "streamInput".data(using: .utf8)!)
        let modifier: NetworkerRequestModifier = .bodyStream(modifierBodyStream)
        // WHEN
        self.request.apply(modifiers: [modifier])
        // THEN
        // TODO: change to XCTAssertIdentical after upgrading to Xcode 12.5
        XCTAssert(self.request.httpBodyStream === modifierBodyStream)
    }

    // MARK: - MainDocumentURL

    func test_GivenMainDocumentURLModifier_WhenAppliedToRequest_ThenRequestHttpBodyShouldMatch() {
        // GIVEN
        let modifierDocumentURL = URL(string: "https://api/document")
        let modifier: NetworkerRequestModifier = .mainDocumentURL(modifierDocumentURL)
        // WHEN
        self.request.apply(modifiers: [modifier])
        // THEN
        XCTAssertEqual(self.request.mainDocumentURL, modifierDocumentURL)
    }

    // MARK: - Custom

    func test_GivenCustomModifier_WhenAppliedToRequest_ThenRequestShouldContainsModifications() {
        // GIVEN
        let modifierCachePolicy: URLRequest.CachePolicy = .returnCacheDataElseLoad
        let modifierServiceType: URLRequest.NetworkServiceType = .background
        let modifierContentType = "application/javascript"
        let modifierDocumentURL = URL(string: "https://api/document")
        let modifier: NetworkerRequestModifier = .custom({ request in
            request.cachePolicy = modifierCachePolicy
            request.networkServiceType = modifierServiceType
            request.addValue(modifierContentType, forHTTPHeaderField: "Content-Type")
            request.mainDocumentURL = modifierDocumentURL
        })
        // WHEN
        self.request.apply(modifiers: [modifier])
        // THEN
        XCTAssertEqual(self.request.cachePolicy, modifierCachePolicy)
        XCTAssertEqual(self.request.networkServiceType, modifierServiceType)
        XCTAssertEqual(self.request.allHTTPHeaderFields?["Content-Type"], modifierContentType)
        XCTAssertEqual(self.request.mainDocumentURL, modifierDocumentURL)
    }
}

