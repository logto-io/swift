//
//  LogtoClient+SignIn.swift
//
//
//  Created by Gao Sun on 2022/1/27.
//

import AuthenticationServices
import Foundation
import Logto

extension LogtoClient {
    func signInWithBrowser<AuthSession: LogtoAuthSession>(
        authSessionType _: AuthSession.Type,
        redirectUri: String
    ) async throws -> Errors.SignIn? {
        guard let redirectUri = URL(string: redirectUri) else {
            return (Errors.SignIn(type: .unableToConstructRedirectUri, innerError: nil))
        }

        let oidcConfig = try await fetchOidcConfig()

        return await withCheckedContinuation { [self] continuation in
            let session = AuthSession(
                logtoConfig: logtoConfig,
                oidcConfig: oidcConfig,
                redirectUri: redirectUri,
                socialPlugins: socialPlugins
            ) { [self] in
                switch $0 {
                case let .failure(error):
                    continuation.resume(returning: error)
                case let .success(response):
                    idToken = response.idToken
                    refreshToken = response.refreshToken
                    accessTokenMap[buildAccessTokenKey(for: nil, scopes: [])] = AccessToken(
                        token: response.accessToken,
                        scope: response.scope,
                        expiresAt: Date().timeIntervalSince1970 + TimeInterval(response.expiresIn)
                    )
                    continuation.resume(returning: nil)
                }
            }

            session.start()
        }
    }

    public func signInWithBrowser(
        redirectUri: String
    ) async throws -> Errors.SignIn? {
        try await signInWithBrowser(
            authSessionType: LogtoAuthSession.self,
            redirectUri: redirectUri
        )
    }
}
