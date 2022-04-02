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

public class LogtoAuthSession {
    public typealias Errors = LogtoClient.Errors

    public enum Result {
        case success(response: LogtoCore.CodeTokenResponse)
        case failure(error: Errors.SignIn)
    }

    public typealias Completion = (Result) -> Void

    let session: NetworkSession
    let authContext: LogtoAuthContext
    let state: String
    let codeVerifier: String
    let codeChallenge: String
    let logtoConfig: LogtoConfig
    let oidcConfig: LogtoCore.OidcConfigResponse
    let redirectUri: URL
    let socialPlugins: [LogtoSocialPlugin]
    let completion: Completion

    internal var callbackUri: URL?

    required init(
        useSession session: NetworkSession = URLSession.shared,
        logtoConfig: LogtoConfig,
        oidcConfig: LogtoCore.OidcConfigResponse,
        redirectUri: URL,
        socialPlugins: [LogtoSocialPlugin],
        completion: @escaping Completion
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
        self.completion = completion
    }

    func start() {
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
                // Create session
                let session = LogtoWebViewAuthSession(authUri, redirectUri: redirectUri,
                                                      socialPlugins: socialPlugins) { [self] in
                    guard let callbackUri = $0 else {
                        completion(.failure(error: Errors.SignIn(type: .authFailed, innerError: nil)))
                        return
                    }

                    await handle(callbackUri: callbackUri)
                }

                DispatchQueue.main.async {
                    session.start()
                }
            #else
                fatalError("LogtoAuthSession does not support macOS currently.")
            #endif
        } catch let error as LogtoErrors.UrlConstruction {
            completion(.failure(error: Errors.SignIn(type: .unableToConstructAuthUri, innerError: error)))
        } catch {
            completion(.failure(error: Errors.SignIn(type: .unknownError, innerError: error)))
        }
    }

    func handle(callbackUri: URL) async {
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
            completion(.success(response: tokenResponse))
        } catch let error as LogtoErrors.UriVerification {
            completion(.failure(error: Errors.SignIn(type: .unexpectedSignInCallback, innerError: error)))
        } catch {
            completion(.failure(error: Errors.SignIn(type: .unableToFetchToken, innerError: error)))
        }
    }
}
