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
    func signInWithBrowser(redirectUri: String, completion: @escaping LogtoCompletion<Errors.SignIn>) {
        guard let redirectUri = URL(string: redirectUri) else {
            completion(.failure(error: Errors.SignIn(type: .unableToConstructRedirectUri, innerError: nil)))
            return
        }

        fetchOidcConfig { [self] oidcConfig, error in
            guard let oidcConfig = oidcConfig else {
                completion(.failure(error: Errors.SignIn(type: .unableToFetchOidcConfig, innerError: error)))
                return
            }

            let session = LogtoSignInSession(
                logtoConfig: logtoConfig,
                oidcConfig: oidcConfig,
                redirectUri: redirectUri
            ) {
                switch $0 {
                case let .failure(error):
                    completion(.failure(error: error))
                case let .success(response):
                    idToken = response.idToken
                    refreshToken = response.refreshToken
                    accessTokenMap[buildAccessTokenKey(scopes: [])] = AccessToken(
                        token: response.accessToken,
                        scope: response.scope,
                        expiresAt: Int64(Date().timeIntervalSince1970 * 1000) + response.expiresIn
                    )
                    print("success", response)
                    completion(.success)
                }
            }

            session.start()
        }
    }
}
