//
//  LogtoAuthSession.swift
//
//
//  Created by Gao Sun on 2022/1/30.
//

import AuthenticationServices
import Foundation
import Logto
import LogtoSocialPlugin

class LogtoAuthSession {
    typealias Errors = LogtoClientErrors

    let session: NetworkSession
    let authContext: LogtoAuthContext
    let state: String
    let codeVerifier: String
    let codeChallenge: String
    let logtoConfig: LogtoConfig
    let oidcConfig: LogtoCore.OidcConfigResponse
    let redirectUri: URL
    let socialPlugins: [LogtoSocialPlugin]

    internal var callbackUri: URL?

    required init(
        useSession session: NetworkSession = URLSession.shared,
        logtoConfig: LogtoConfig,
        oidcConfig: LogtoCore.OidcConfigResponse,
        redirectUri: URL,
        socialPlugins: [LogtoSocialPlugin]
    ) {
        authContext = LogtoAuthContext()
        state = LogtoUtilities.generateState()
        codeVerifier = LogtoUtilities.generateCodeVerifier()
        codeChallenge = LogtoUtilities.generateCodeChallenge(codeVerifier: codeVerifier)

        self.session = session
        self.logtoConfig = logtoConfig
        self.oidcConfig = oidcConfig
        self.redirectUri = redirectUri
        self.socialPlugins = socialPlugins
    }

    func start() async throws -> LogtoCore.CodeTokenResponse {
        do {
            let authUri = try LogtoCore.generateSignInUri(
                authorizationEndpoint: oidcConfig.authorizationEndpoint,
                clientId: logtoConfig.clientId,
                redirectUri: redirectUri,
                codeChallenge: codeChallenge,
                state: state,
                scopes: logtoConfig.scopes,
                resources: logtoConfig.resources
            )

            #if !os(macOS)
                return try await withCheckedThrowingContinuation { continuation in
                    // Create session
                    let session = LogtoWebViewAuthSession(
                        authUri,
                        redirectUri: redirectUri,
                        socialPlugins: socialPlugins
                    ) { [self] in
                        guard let callbackUri = $0 else {
                            continuation.resume(throwing: Errors.SignIn(type: .authFailed, innerError: nil))
                            return
                        }

                        do {
                            let response = try await handle(callbackUri: callbackUri)
                            continuation.resume(returning: response)
                        } catch {
                            continuation.resume(throwing: error)
                        }
                    }

                    DispatchQueue.main.async {
                        session.start()
                    }
                }
            #else
                fatalError("LogtoAuthSession does not support macOS currently.")
            #endif
        } catch let error as LogtoErrors.UrlConstruction {
            throw Errors.SignIn(type: .unableToConstructAuthUri, innerError: error)
        } catch {
            throw Errors.SignIn(type: .unknownError, innerError: error)
        }
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
                clientId: logtoConfig.clientId,
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
