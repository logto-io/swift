//
//  LogtoWebAuthSession.swift
//
//
//  Created by Gao Sun on 2022/2/12.
//

import AuthenticationServices
import Foundation

protocol LogtoWebAuthSession {
    init(url: URL, callbackURLScheme: String?, completionHandler: @escaping (URL?, Error?) -> Void)

    @discardableResult func start() -> Bool
}

extension ASWebAuthenticationSession: LogtoWebAuthSession {}
