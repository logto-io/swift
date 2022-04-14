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

public class LogtoWebViewAuthViewController: UnifiedViewController {
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
            .messageHandlerName),
                supportedSocialConnectorIds: [\(supportedSocialConnectorIds)],
                callbackUriScheme: '\(LogtoWebViewAuthViewController.webAuthCallbackScheme)'
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
        webView.navigationDelegate = authSession
        webView.configuration.userContentController.add(self, name: LogtoWebViewAuthViewController.messageHandlerName)
        webView.configuration.userContentController
            .addUserScript(WKUserScript(source: injectScript, injectionTime: .atDocumentStart, forMainFrameOnly: false))
    }

    override public func viewDidLoad() {
        webView.load(URLRequest(url: authSession.uri))
    }

    func postErrorMessage(_ error: LogtoSocialPluginError) {
        webView.evaluateJavaScript("""
            window.postMessage({
                type: 'error',
                code: '\(error.code)',
                description: '\(error.localizedDescription)'
            }, location.origin);
        """)
    }
}

extension LogtoWebViewAuthViewController: ASWebAuthenticationPresentationContextProviding {
    public func presentationAnchor(for _: ASWebAuthenticationSession) -> ASPresentationAnchor {
        view.window!
    }
}

extension LogtoWebViewAuthViewController: WKScriptMessageHandler {
    struct SocialPostBody: Codable {
        static func safeParseJson(json: Any) -> SocialPostBody? {
            do {
                let data = try JSONSerialization.data(withJSONObject: json)
                return try? JSONDecoder().decode(self, from: data)
            } catch {
                return nil
            }
        }

        let callbackUri: String
        let redirectTo: String
    }

    public func userContentController(_: WKUserContentController, didReceive message: WKScriptMessage) {
        guard let body = SocialPostBody.safeParseJson(json: message.body),
              let redirectUri = URL(string: body.redirectTo),
              let redirectScheme = URLComponents(url: redirectUri, resolvingAgainstBaseURL: true)?.scheme,
              let callbackUri = URL(string: body.callbackUri)
        else {
            return
        }

        guard let socialPlugin = authSession.socialPlugins.first(where: {
            $0.urlSchemes.contains(redirectScheme)
        }) else {
            // TO-DO: error handling
            return
        }

        socialPlugin
            .start(LogtoSocialPluginConfiguration(
                redirectUri: redirectUri,
                callbackUri: callbackUri,
                completion: { url in
                    self.webView.load(URLRequest(url: url))
                }, errorHandler: postErrorMessage
            ))
    }
}
