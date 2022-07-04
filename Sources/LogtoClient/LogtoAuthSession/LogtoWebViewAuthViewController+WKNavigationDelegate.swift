//
//  LogtoWebViewAuthViewController+WKNavigationDelegate.swift
//
//
//  Created by Gao Sun on 2022/4/19.
//

import Foundation
import WebKit

extension LogtoWebViewAuthViewController: WKNavigationDelegate {
    public func webView(
        _: WKWebView,
        decidePolicyFor navigationAction: WKNavigationAction
    ) async -> WKNavigationActionPolicy {
        if let url = navigationAction.request.url, !["http", "https"].contains(url.scheme) {
            if
                let scheme = url.scheme,
                scheme.lowercased() == authSession.redirectUri.scheme?.lowercased(),
                url.host == authSession.redirectUri.host,
                url.path == authSession.redirectUri.path
            {
                await authSession.didFinish(url: url)
            }
            return .cancel
        }

        return .allow
    }

    func webView(_: WKWebView, didStartProvisionalNavigation _: WKNavigation!) {
        activityIndicator.startAnimating()
    }

    func webView(_: WKWebView, didFinish _: WKNavigation!) {
        activityIndicator.stopAnimating()
    }

    func webView(_: WKWebView, didFail _: WKNavigation!, withError _: Error) {
        activityIndicator.stopAnimating()
    }
}
