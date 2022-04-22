//
//  LogtoWebViewAuthViewControllerTest.swift
//
//
//  Created by Gao Sun on 2022/4/14.
//

import AuthenticationServices
import Foundation
@testable import LogtoClient
import WebKit
import XCTest

class SocialPluginMock: LogtoSocialPlugin {
    let connectorId = "id"
    let urlSchemes = ["mock"]

    var startCalled = false

    func start(_ configuration: LogtoSocialPluginConfiguration) {
        startCalled = true

        guard !configuration.redirectTo.absoluteString.contains("error") else {
            configuration.errorHandler(LogtoSocialPluginError.unableToConstructCallbackUri)
            return
        }

        configuration.completion(configuration.redirectTo)
    }
}

class ScriptMessageMock: WKScriptMessage {
    let _body: Any

    override var body: Any {
        _body
    }

    init(_ body: Any) {
        _body = body
    }
}

final class LogtoWebViewAuthViewControllerTest: XCTestCase {
    let mockUrl = URL(string: "https://logto.dev/")!

    func createViewController(socialPlugins: [LogtoSocialPlugin] = [])
        -> (LogtoWebViewAuthViewController, LogtoWebViewAuthSession)
    {
        let authSession = LogtoWebViewAuthSession(
            mockUrl,
            redirectUri: mockUrl,
            socialPlugins: socialPlugins,
            onFinish: { _ in }
        )
        let viewController = LogtoWebViewAuthViewController(authSession: authSession)
        return (viewController, authSession)
    }

    func testLoadView() {
        let (viewController, _) = createViewController(socialPlugins: [LogtoSocialPluginWeb()])
        viewController.loadView()

        XCTAssertEqual(viewController.view, viewController.webView)
        XCTAssertEqual(viewController.webView.navigationDelegate as? LogtoWebViewAuthViewController, viewController)
        XCTAssertTrue(viewController.webView.configuration.userContentController.userScripts.contains(where: {
            $0.source == viewController.injectScript
        }))
    }

    func testViewDidLoad() {
        let (viewController, authSession) = createViewController()
        viewController.viewDidLoad()

        XCTAssertEqual(viewController.webView.url, authSession.uri)
    }

    func testPostErrorMessage() {
        let expectation = XCTestExpectation(description: "Evaluate JS")
        let (viewController, _) = createViewController()

        viewController.postErrorMessage(
            LogtoSocialPluginError.authenticationFailed(socialCode: nil, socialMessage: nil)
        ) {
            XCTAssertNil($0)
            // This is intended since our JS doesn't return
            XCTAssertEqual(($1 as? NSError)?.code, 4)
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 5)
    }

    func testPresentationAnchor() {
        let window = UIWindow()
        let (viewController, _) = createViewController()

        window.makeKeyAndVisible()
        window.rootViewController = viewController

        XCTAssertEqual(
            viewController.view.window,
            viewController
                .presentationAnchor(for: ASWebAuthenticationSession(url: mockUrl, callbackURLScheme: nil,
                                                                    completionHandler: { _, _ in }))
        )
    }

    func testSocialPostBodySageParseJson() {
        // The following test case always throws even the function is not throwable. Interesting.
        // XCTAssertNil(LogtoWebViewAuthViewController.SocialPostBody.safeParseJson(json: 1))
        XCTAssertNil(LogtoWebViewAuthViewController.SocialPostBody.safeParseJson(json: ["foo": "bar"]))
        XCTAssertNotNil(LogtoWebViewAuthViewController.SocialPostBody
            .safeParseJson(json: ["callbackUri": "foo", "redirectTo": "bar"]))
    }

    func testUserContentController() {
        let socialPlugin = SocialPluginMock()
        let (viewController, _) = createViewController(socialPlugins: [socialPlugin])

        viewController.userContentController(WKUserContentController(), didReceive: ScriptMessageMock([:]))
        XCTAssertFalse(socialPlugin.startCalled)

        viewController.userContentController(WKUserContentController(), didReceive: ScriptMessageMock(
            ["callbackUri": mockUrl.absoluteString, "redirectTo": mockUrl.absoluteString]
        ))
        XCTAssertFalse(socialPlugin.startCalled)

        viewController.userContentController(WKUserContentController(), didReceive: ScriptMessageMock(
            ["callbackUri": mockUrl.absoluteString, "redirectTo": "mock://url"]
        ))
        XCTAssertTrue(socialPlugin.startCalled)
        XCTAssertEqual(viewController.webView.url, URL(string: "mock://url")!)
    }

    func testUserContentControllerError() {
        let socialPlugin = SocialPluginMock()
        let (viewController, _) = createViewController(socialPlugins: [socialPlugin])

        viewController.userContentController(WKUserContentController(), didReceive: ScriptMessageMock(
            ["callbackUri": mockUrl.absoluteString, "redirectTo": "mock://error"]
        ))
        XCTAssertTrue(socialPlugin.startCalled)
        XCTAssertNil(viewController.webView.url)
    }
}
