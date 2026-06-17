//
//  LogtoClient+SignIn.swift
//
//
//  Created by Gao Sun on 2022/1/27.
//

import Foundation
import Logto

extension LogtoClient {
    @MainActor
    func signInWithBrowser<AuthSession: LogtoAuthSession>(
        authSessionType _: AuthSession.Type,
        redirectUri: String,
        loginHint: String? = nil,
        directSignIn: LogtoCore.DirectSignInOptions? = nil,
        extraParams: [String: String]? = nil
    ) async throws {
        guard let redirectUri = URL(string: redirectUri) else {
            throw (LogtoClientErrors.SignIn(type: .unableToConstructRedirectUri, innerError: nil))
        }

        guard !isSigningIn else {
            throw LogtoClientErrors.SignIn(type: .signInSessionAlreadyInProgress, innerError: nil)
        }

        isSigningIn = true
        defer {
            isSigningIn = false
        }

        let oidcConfig = try await fetchOidcConfig()

        let session = AuthSession(
            logtoConfig: logtoConfig,
            oidcConfig: oidcConfig,
            redirectUri: redirectUri,
            loginHint: loginHint,
            directSignIn: directSignIn,
            extraParams: extraParams
        )

        let response = try await session.start()
        let jwks = try await fetchJwkSet()

        try response.idToken.map {
            try LogtoUtilities.verifyIdToken(
                $0,
                issuer: oidcConfig.issuer,
                clientId: logtoConfig.appId,
                jwks: jwks
            )
        }

        idToken = response.idToken
        refreshToken = response.refreshToken
        accessTokenMap[buildAccessTokenKey(for: nil, in: nil)] = AccessToken(
            token: response.accessToken,
            scope: response.scope,
            expiresAt: Date().timeIntervalSince1970 + TimeInterval(response.expiresIn)
        )
    }
}

public extension LogtoClient {
    #if os(iOS)
        /**
         Start a sign in session with ASWebAuthenticationSession. If the function returns with no error threw, it means the user has signed in successfully.

         - Parameters:
            - redirectUri: One of Redirect URIs of this application.
            - loginHint: Login hint indicates the current user (usually an email address or phone number).
            - directSignIn: Parameters for direct sign-in.
            - extraParams: Extra parameters for the authentication request.
         - Throws: An error if the session failed to complete.
         */
        @MainActor
        func signInWithBrowser(
            redirectUri: String,
            loginHint: String? = nil,
            directSignIn: LogtoCore.DirectSignInOptions? = nil,
            extraParams: [String: String]? = nil
        ) async throws {
            try await signInWithBrowser(
                authSessionType: LogtoASWebAuthenticationSession.self,
                redirectUri: redirectUri,
                loginHint: loginHint,
                directSignIn: directSignIn,
                extraParams: extraParams
            )
        }
    #else
        @available(*, unavailable, message: "Browser sign-in is currently available on iOS only.")
        @MainActor
        func signInWithBrowser(
            redirectUri _: String,
            loginHint _: String? = nil,
            directSignIn _: LogtoCore.DirectSignInOptions? = nil,
            extraParams _: [String: String]? = nil
        ) async throws {
            fatalError("Browser sign-in is currently available on iOS only.")
        }
    #endif
}
