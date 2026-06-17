//
//  LogtoAuthSession.swift
//
//
//  Created by Gao Sun on 2022/1/30.
//

import Foundation
import Logto

class LogtoAuthSession {
    typealias Errors = LogtoClientErrors

    let session: NetworkSession
    let state: String
    let codeVerifier: String
    let codeChallenge: String
    let logtoConfig: LogtoConfig
    let oidcConfig: LogtoCore.OidcConfigResponse
    let redirectUri: URL
    let loginHint: String?
    let directSignIn: LogtoCore.DirectSignInOptions?
    let extraParams: [String: String]?

    internal var callbackUri: URL?

    required init(
        useSession session: NetworkSession = URLSession.shared,
        logtoConfig: LogtoConfig,
        oidcConfig: LogtoCore.OidcConfigResponse,
        redirectUri: URL,
        loginHint: String? = nil,
        directSignIn: LogtoCore.DirectSignInOptions? = nil,
        extraParams: [String: String]? = nil
    ) {
        state = LogtoUtilities.generateState()
        codeVerifier = LogtoUtilities.generateCodeVerifier()
        codeChallenge = LogtoUtilities.generateCodeChallenge(codeVerifier: codeVerifier)

        self.session = session
        self.logtoConfig = logtoConfig
        self.oidcConfig = oidcConfig
        self.redirectUri = redirectUri
        self.loginHint = loginHint
        self.directSignIn = directSignIn
        self.extraParams = extraParams
    }

    func start() async throws -> LogtoCore.CodeTokenResponse {
        throw Errors.SignIn(type: .authFailed, innerError: nil)
    }

    func generateSignInUri() throws -> URL {
        try LogtoCore.generateSignInUri(
            authorizationEndpoint: oidcConfig.authorizationEndpoint,
            clientId: logtoConfig.appId,
            redirectUri: redirectUri,
            codeChallenge: codeChallenge,
            state: state,
            scopes: logtoConfig.scopes,
            resources: logtoConfig.resources,
            prompt: logtoConfig.prompt,
            loginHint: loginHint,
            directSignIn: directSignIn,
            extraParams: extraParams
        )
    }

    func handle(callbackUri: URL) async throws -> LogtoCore.CodeTokenResponse {
        do {
            let code = try LogtoCore.verifyAndParseSignInCallbackUri(
                callbackUri,
                redirectUri: redirectUri,
                state: state
            )
            let tokenResponse = try await LogtoCore.fetchToken(
                useSession: session,
                byAuthorizationCode: code,
                codeVerifier: codeVerifier,
                tokenEndpoint: oidcConfig.tokenEndpoint,
                clientId: logtoConfig.appId,
                redirectUri: redirectUri.absoluteString
            )
            return tokenResponse
        } catch let error as LogtoErrors.UriVerification {
            throw Errors.SignIn(type: .unexpectedSignInCallback, innerError: error)
        } catch {
            throw Errors.SignIn(type: .unableToFetchToken, innerError: error)
        }
    }
}
