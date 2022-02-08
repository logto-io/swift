//
//  LogtoClient+SignIn.swift
//
//
//  Created by Gao Sun on 2022/1/27.
//

import AuthenticationServices
import Foundation
import Logto

public extension LogtoClient {
    func signInWithBrowser(redirectUri: String, completion: @escaping EmptyCompletion<Errors.SignIn>) {
        guard let redirectUri = URL(string: redirectUri) else {
            completion(Errors.SignIn(type: .unableToConstructRedirectUri, innerError: nil))
            return
        }

        fetchOidcConfig { [self] oidcConfig, error in
            guard let oidcConfig = oidcConfig else {
                completion(Errors.SignIn(type: .unableToFetchOidcConfig, innerError: error))
                return
            }

            let session = LogtoSignInSession(
                logtoConfig: logtoConfig,
                oidcConfig: oidcConfig,
                redirectUri: redirectUri
            ) {
                switch $0 {
                case let .failure(error):
                    completion(error)
                case let .success(response):
                    idToken = response.idToken
                    refreshToken = response.refreshToken
                    accessTokenMap[buildAccessTokenKey(for: nil, scopes: [])] = AccessToken(
                        token: response.accessToken,
                        scope: response.scope,
                        expiresAt: Date().timeIntervalSince1970 + TimeInterval(response.expiresIn)
                    )
                    completion(nil)
                }
            }

            session.start()
        }
    }
}
