//
//  LogtoWebViewAuthViewController.swift
//
//
//  Created by Gao Sun on 2022/3/22.
//

import AuthenticationServices
import Foundation
import WebKit

public class LogtoWebViewAuthViewController: UnifiedViewController {
    let webView = WKWebView()
    let authSession: LogtoWebViewAuthSession

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
        webView.configuration.userContentController.add(self, name: "socialHandler")
    }

    override public func viewDidLoad() {
        webView.load(URLRequest(url: authSession.uri))
    }

    func postErrorMessage(_ error: LogtoWebViewAuthViewError) {
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
    static let webAuthCallbackScheme = "logto-callback"

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
              let callbackUri = URL(string: body.callbackUri),
              var callbackComponents = URLComponents(url: callbackUri, resolvingAgainstBaseURL: true)
        else {
            return
        }

        let session = ASWebAuthenticationSession(
            url: redirectUri,
            callbackURLScheme: LogtoWebViewAuthViewController.webAuthCallbackScheme
        ) { [self] customUri, error in
            guard let customUri = customUri else {
                postErrorMessage(.webAuthFailed(innerError: error))
                return
            }

            // Construct callback URL for WebView
            let customComponents = URLComponents(url: customUri, resolvingAgainstBaseURL: true)
            callbackComponents
                .queryItems = (callbackComponents.queryItems ?? []) + (customComponents?.queryItems ?? [])

            guard let url = callbackComponents.url else {
                postErrorMessage(.unableToConstructCallbackUri)
                return
            }

            self.webView.load(URLRequest(url: url))
        }

        session.prefersEphemeralWebBrowserSession = true
        session.presentationContextProvider = self
        session.start()
    }
}
