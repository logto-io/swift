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
    let activityIndicator = UIActivityIndicatorView()
    let authSession: LogtoWebViewAuthSession

    var injectScript: String {
        let plugins = authSession.socialPlugins
        let supportedNativeConnectorTargets = plugins
            .filter { $0.isAvailable }
            .compactMap { $0.connectorTarget }
            .map { "'\($0)'" }
            .joined(separator: ",")

        return """
            const logtoNativeSdk = {
                platform: 'ios',
                getPostMessage: () => window.webkit.messageHandlers && window.webkit.messageHandlers.\(
                    LogtoWebViewAuthViewController.messageHandlerName
                ).postMessage.bind(window.webkit.messageHandlers.\(LogtoWebViewAuthViewController.messageHandlerName)),
                supportedConnector: {
                    universal: \(plugins.contains(where: { $0.connectorPlatform == .universal })),
                    nativeTargets: [\(supportedNativeConnectorTargets)]
                },
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
        view = UIView()

        webView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        webView.isOpaque = false
        webView.backgroundColor = .systemBackground
        webView.scrollView.contentInsetAdjustmentBehavior = .never
        webView.navigationDelegate = self
        webView.configuration.userContentController.add(self, name: LogtoWebViewAuthViewController.messageHandlerName)
        webView.configuration.userContentController
            .addUserScript(WKUserScript(source: injectScript, injectionTime: .atDocumentStart, forMainFrameOnly: false))
        view.addSubview(webView)

        activityIndicator.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        activityIndicator.center = view.center
        activityIndicator.hidesWhenStopped = true
        activityIndicator.style = .medium
        view.addSubview(activityIndicator)
    }

    override public func viewDidLoad() {
        webView.load(URLRequest(url: authSession.uri))
    }

    override public func viewDidDisappear(_: Bool) {
        Task {
            await authSession.didFinish(url: nil)

            // Delete related cookies asyncly when view disappeared
            if let host = authSession.uri.host {
                WKWebsiteDataStore.default().httpCookieStore.getAllCookies { cookies in
                    cookies.forEach {
                        if $0.domain == host {
                            WKWebsiteDataStore.default().httpCookieStore.delete($0)
                        }
                    }
                }
            }
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
