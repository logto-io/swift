//
//  LogtoWebViewAuthViewController.swift
//
//
//  Created by Gao Sun on 2022/3/22.
//

import AuthenticationServices
import Foundation
import LogtoSocialPlugin
import WebKit

class LogtoWebViewAuthViewController: UnifiedViewController {
    static let webAuthCallbackScheme = "logto-callback"
    static let messageHandlerName = "socialHandler"

    let webView = WKWebView()
    let authSession: LogtoWebViewAuthSession

    var injectScript: String {
        let supportedSocialConnectorIds = authSession
            .socialPlugins.filter { $0.isAvailable }
            .map { "'\($0.connectorId)'" }
            .joined(separator: ",")

        return """
            const logtoNativeSdk = {
                platform: 'ios',
                getPostMessage: () => window.webkit.messageHandlers && window.webkit.messageHandlers.\(LogtoWebViewAuthViewController
            .messageHandlerName).postMessage.bind(window.webkit.messageHandlers.\(LogtoWebViewAuthViewController
            .messageHandlerName)),
                supportedSocialConnectorIds: [\(supportedSocialConnectorIds)],
                callbackLink: '\(LogtoWebViewAuthViewController.webAuthCallbackScheme)://web'
            };
        """
    }

    init(authSession: LogtoWebViewAuthSession) {
        self.authSession = authSession
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override public func loadView() {
        view = webView
        webView.scrollView.contentInsetAdjustmentBehavior = .never
        webView.navigationDelegate = self
        webView.configuration.userContentController.add(self, name: LogtoWebViewAuthViewController.messageHandlerName)
        webView.configuration.userContentController
            .addUserScript(WKUserScript(source: injectScript, injectionTime: .atDocumentStart, forMainFrameOnly: false))
    }

    override public func viewDidLoad() {
        webView.load(URLRequest(url: authSession.uri))
    }

    override public func viewDidDisappear(_: Bool) {
        Task {
            await authSession.didFinish(url: nil)
        }
    }

    func postErrorMessage(_ error: LogtoSocialPluginError, completion: ((Any?, Error?) -> Void)? = nil) {
        webView.evaluateJavaScript("""
            window.postMessage({
                type: 'error',
                code: '\(error.code)',
                description: '\(error.localizedDescription)'
            }, location.origin);
        """, completionHandler: completion)
    }
}

extension LogtoWebViewAuthViewController: ASWebAuthenticationPresentationContextProviding {
    public func presentationAnchor(for _: ASWebAuthenticationSession) -> ASPresentationAnchor {
        view.window!
    }
}
