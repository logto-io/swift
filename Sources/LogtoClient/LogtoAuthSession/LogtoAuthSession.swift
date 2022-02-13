//
//  LogtoAuthSession.swift
//
//
//  Created by Gao Sun on 2022/1/30.
//

import AuthenticationServices
import Foundation
import Logto

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
    let completion: Completion

    internal var callbackUri: URL?

    required init(
        useSession session: NetworkSession = URLSession.shared,
        logtoConfig: LogtoConfig,
        oidcConfig: LogtoCore.OidcConfigResponse,
        redirectUri: URL,
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
        self.completion = completion
    }

    func start<WebAuthSession: LogtoWebAuthSession>(withSessionType _: WebAuthSession.Type) {
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

            // Create session
            let session = WebAuthSession(url: authUri, callbackURLScheme: redirectUri.scheme) { [self] in
                guard let callbackUri = $0 else {
                    completion(.failure(error: Errors.SignIn(type: .authFailed, innerError: $1)))
                    return
                }

                handle(callbackUri: callbackUri)
            }

            if #available(iOS 13.0, *), let session = session as? ASWebAuthenticationSession {
                session.presentationContextProvider = self.authContext
                session.prefersEphemeralWebBrowserSession = true
            }

            DispatchQueue.main.async {
                session.start()
            }
        } catch let error as LogtoErrors.UrlConstruction {
            completion(.failure(error: Errors.SignIn(type: .unableToConstructAuthUri, innerError: error)))
        } catch {
            completion(.failure(error: Errors.SignIn(type: .unknownError, innerError: error)))
        }
    }

    public func start() {
        start(withSessionType: ASWebAuthenticationSession.self)
    }

    func handle(callbackUri: URL) {
        do {
            let code = try LogtoCore.verifyAndParseSignInCallbackUri(
                callbackUri,
                redirectUri: redirectUri,
                state: state
            )
            LogtoCore.fetchToken(
                useSession: session,
                byAuthorizationCode: code,
                codeVerifier: codeVerifier,
                tokenEndpoint: oidcConfig.tokenEndpoint,
                clientId: logtoConfig.clientId,
                redirectUri: redirectUri.absoluteString
            ) { [self] in
                guard let tokenResponse = $0 else {
                    completion(.failure(error: Errors.SignIn(type: .unableToFetchToken, innerError: $1)))
                    return
                }

                completion(.success(response: tokenResponse))
            }
        } catch {
            completion(.failure(error: Errors.SignIn(type: .unexpectedSignInCallback, innerError: error)))
        }
    }
}
