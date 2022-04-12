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
    ) async throws {
        guard let redirectUri = URL(string: redirectUri) else {
            throw (Errors.SignIn(type: .unableToConstructRedirectUri, innerError: nil))
        }

        let oidcConfig = try await fetchOidcConfig()

        let session = AuthSession(
            logtoConfig: logtoConfig,
            oidcConfig: oidcConfig,
            redirectUri: redirectUri,
            socialPlugins: socialPlugins
        )

        let response = try await session.start()

        idToken = response.idToken

        if let idToken = idToken {
            let jwks = try await fetchJwkSet()
            try LogtoUtilities.verifyIdToken(
                idToken,
                issuer: oidcConfig.issuer,
                clientId: logtoConfig.clientId,
                jwks: jwks
            )
        }

        refreshToken = response.refreshToken
        accessTokenMap[buildAccessTokenKey(for: nil, scopes: [])] = AccessToken(
            token: response.accessToken,
            scope: response.scope,
            expiresAt: Date().timeIntervalSince1970 + TimeInterval(response.expiresIn)
        )
    }

    public func signInWithBrowser(
        redirectUri: String
    ) async throws {
        try await signInWithBrowser(
            authSessionType: LogtoAuthSession.self,
            redirectUri: redirectUri
        )
    }
}
