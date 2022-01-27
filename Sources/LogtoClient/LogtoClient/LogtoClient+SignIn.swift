//
//  LogtoClient+SignIn.swift
//
//
//  Created by Gao Sun on 2022/1/27.
//

import Foundation
import Logto

public extension LogtoClient {
    internal func fetchOidcConfig(completion: @escaping HttpCompletion<LogtoCore.OidcConfigResponse>) {
        guard oidcConfig == nil else {
            completion(oidcConfig, nil)
            return
        }

        let requestCompletion: HttpCompletion<LogtoCore.OidcConfigResponse> = { config, error in
            if error != nil || config == nil {
                completion(nil, error ?? LogtoClientErrors.Fetch.unableToFetchOidcConfig)
                return
            }

            self.oidcConfig = config
            completion(config, nil)
        }

        LogtoRequest.get(
            useSession: networkSession,
            url: logtoConfig.endpoint.appendingPathComponent("/oidc/.well-known/openid-configuration"),
            completion: requestCompletion
        )
    }

    func signInWithBrowser() {
        fetchOidcConfig { _, _ in
            // To implement
        }
    }
}
