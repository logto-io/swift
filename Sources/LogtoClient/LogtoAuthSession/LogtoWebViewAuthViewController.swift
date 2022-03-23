//
//  LogtoWebViewAuthViewController.swift
//
//
//  Created by Gao Sun on 2022/3/22.
//

import Foundation
import WebKit

public class LogtoWebViewAuthViewController: NSViewController {
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
    }

    override public func viewDidLoad() {
        webView.load(URLRequest(url: authSession.uri))
    }
}
