//
//  LogtoWebViewAuthViewController+WKScriptMessageHandler.swift
//
//
//  Created by Gao Sun on 2022/4/19.
//

import Foundation
import WebKit

extension LogtoWebViewAuthViewController: WKScriptMessageHandler {
    struct SocialPostBody: Codable {
        static func safeParseJson(json: Any) -> SocialPostBody? {
            guard let data = try? JSONSerialization.data(withJSONObject: json) else {
                return nil
            }
            return try? JSONDecoder().decode(self, from: data)
        }

        let callbackUri: String
        let redirectTo: String
    }

    public func userContentController(_: WKUserContentController, didReceive message: WKScriptMessage) {
        guard let body = SocialPostBody.safeParseJson(json: message.body),
              let redirectTo = URL(string: body.redirectTo),
              let redirectScheme = URLComponents(url: redirectTo, resolvingAgainstBaseURL: true)?.scheme,
              let callbackUri = URL(string: body.callbackUri)
        else {
            return
        }

        guard let socialPlugin = authSession.socialPlugins.first(where: {
            $0.urlSchemes.contains(redirectScheme)
        }) else {
            Task {
                await authSession.didFinish(url: nil)
            }
            return
        }

        socialPlugin
            .start(LogtoSocialPluginConfiguration(
                redirectTo: redirectTo,
                callbackUri: callbackUri,
                completion: { self.webView.load(URLRequest(url: $0)) },
                errorHandler: { self.postErrorMessage($0) }
            ))
    }
}
