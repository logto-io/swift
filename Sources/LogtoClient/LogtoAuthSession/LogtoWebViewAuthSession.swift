//
//  LogtoWebViewAuthSession.swift
//
//
//  Created by Gao Sun on 2022/3/22.
//

import Foundation
import LogtoSocialPlugin
import WebKit

public class LogtoWebViewAuthSession: NSObject {
    public typealias FinishHandler = (URL?) async -> Void

    let uri: URL
    let redirectUri: URL
    let socialPlugins: [LogtoSocialPlugin]
    let onFinish: FinishHandler
    var viewController: LogtoWebViewAuthViewController?

    public init(_ uri: URL, redirectUri: URL, socialPlugins: [LogtoSocialPlugin], onFinish: @escaping FinishHandler) {
        self.uri = uri
        self.redirectUri = redirectUri
        self.socialPlugins = socialPlugins
        self.onFinish = onFinish
        super.init()
    }

    #if !os(macOS)
        func getTopViewController() -> UnifiedViewController? {
            if var topController = UIApplication.shared.windows.filter({ $0.isKeyWindow }).first?.rootViewController {
                while let presentedViewController = topController.presentedViewController {
                    topController = presentedViewController
                }

                return topController
            }

            return nil
        }
    #else
        func getTopViewController() -> UnifiedViewController? {
            NSApplication.shared.keyWindow?.contentViewController
        }
    #endif

    @discardableResult public func start() -> Bool {
        guard let topViewController = getTopViewController() else {
            return false
        }

        let viewController = LogtoWebViewAuthViewController(authSession: self)
        #if !os(macOS)
            topViewController.present(viewController, animated: true)
            self.viewController = viewController
            return true
        #else
            fatalError("LogtoWebViewAuthSession does not support macOS yet.")
        #endif
    }

    internal func didFinish(url: URL?) async {
        await onFinish(url)
        DispatchQueue.main.async {
            #if !os(macOS)
                self.viewController?.dismiss(animated: true, completion: {
                    self.viewController = nil
                })
            #else
                fatalError("LogtoWebViewAuthSession does not support macOS yet.")
            #endif
        }
    }
}

extension LogtoWebViewAuthSession: WKNavigationDelegate {
    public func webView(
        _: WKWebView,
        decidePolicyFor navigationAction: WKNavigationAction
    ) async -> WKNavigationActionPolicy {
        if let url = navigationAction.request.url, !["http", "https"].contains(url.scheme) {
            if
                let scheme = url.scheme,
                scheme.lowercased() == redirectUri.scheme?.lowercased(),
                url.host == redirectUri.host,
                url.path == redirectUri.path
            {
                await didFinish(url: url)
            }
            return .cancel
        }

        return .allow
    }
}
