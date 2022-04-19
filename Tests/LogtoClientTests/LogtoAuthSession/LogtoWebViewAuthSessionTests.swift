//
//  LogtoWebViewAuthSessionTests.swift
//
//
//  Created by Gao Sun on 2022/4/14.
//

import Foundation
@testable import LogtoClient
import WebKit
import XCTest

class LogtoWebViewAuthSessionMock: LogtoWebViewAuthSession {
    let viewControllerMock = UIViewController()

    override func getTopViewController() -> UnifiedViewController? {
        viewControllerMock
    }
}

final class WKNavigationActionMock: WKNavigationAction {
    override var request: URLRequest { urlRequest }
    let urlRequest: URLRequest

    init(urlRequest: URLRequest) {
        self.urlRequest = urlRequest
        super.init()
    }
}

final class LogtoWebViewAuthSessionTests: XCTestCase {
    let mockUrl = URL(string: "https://logto.dev")!

    func testStartWithNoTopViewController() {
        let session = LogtoWebViewAuthSession(mockUrl, redirectUri: mockUrl, socialPlugins: []) { _ in }

        XCTAssertEqual(session.start(), false)
    }

    @MainActor
    func testStartOk() {
        let session = LogtoWebViewAuthSessionMock(mockUrl, redirectUri: mockUrl, socialPlugins: []) { _ in }

        XCTAssertEqual(session.start(), true)
    }

    actor CalledUrl {
        var value: URL?

        func update(_ value: URL?) {
            self.value = value
        }
    }

    @MainActor
    func testDidfinishOk() async throws {
        let calledUrl = CalledUrl()
        let session = LogtoWebViewAuthSessionMock(mockUrl, redirectUri: mockUrl, socialPlugins: []) {
            await calledUrl.update($0)
        }

        session.start()
        await session.didFinish(url: mockUrl)

        let value = await calledUrl.value
        XCTAssertEqual(value, mockUrl)

        try await Task.sleep(nanoseconds: UInt64(0.05 * Double(NSEC_PER_SEC)))
        XCTAssertNil(session.viewController)
    }

    func testDelegateNavigationActionAllow() async {
        let session = LogtoWebViewAuthSession(mockUrl, redirectUri: mockUrl, socialPlugins: []) { _ in }
        let controller = await LogtoWebViewAuthViewController(authSession: session)

        let task = Task { @MainActor in
            let result = await controller.webView(
                WKWebView(),
                decidePolicyFor: WKNavigationActionMock(urlRequest: URLRequest(url: mockUrl))
            )
            XCTAssertEqual(result, .allow)
        }

        await task.value
    }

    func testDelegateNavigationActionCancel() async {
        let mockUrl = URL(string: "logto://callback/path")!
        let session = LogtoWebViewAuthSession(mockUrl, redirectUri: mockUrl, socialPlugins: []) { _ in }
        let controller = await LogtoWebViewAuthViewController(authSession: session)

        let task = Task { @MainActor in
            let result = await controller.webView(
                WKWebView(),
                decidePolicyFor: WKNavigationActionMock(urlRequest: URLRequest(url: mockUrl))
            )
            XCTAssertEqual(result, .cancel)
        }

        await task.value
    }
}
