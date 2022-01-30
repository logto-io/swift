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
    enum SignInResult {
        case success
        case failure(error: Errors.SignIn)
    }

    typealias SignInCompletion = (SignInResult) -> Void

    internal func fetchOidcConfig(completion: @escaping HttpCompletion<LogtoCore.OidcConfigResponse>) {
        guard oidcConfig == nil else {
            completion(oidcConfig, nil)
            return
        }

        let requestCompletion: HttpCompletion<LogtoCore.OidcConfigResponse> = { config, error in
            if error != nil || config == nil {
                completion(nil, error ?? Errors.Fetch.unableToFetchOidcConfig)
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

    internal func startSession(
        oidcConfig: LogtoCore.OidcConfigResponse,
        redirectUri: URL,
        completion: @escaping SignInCompletion
    ) {
        do {
            // Construct auth URI
            let state = LogtoUtilities.generateState()
            let codeVerifier = LogtoUtilities.generateCodeVerifier()
            let codeChallenge = LogtoUtilities.generateCodeChallenge(codeVerifier: codeVerifier)
            let authUri = try LogtoCore.generateSignInUri(
                authorizationEndpoint: oidcConfig.authorizationEndpoint,
                clientId: logtoConfig.clientId,
                redirectUri: redirectUri,
                codeChallenge: codeChallenge,
                state: state,
                scope: nil,
                resource: nil
            )

            // Create session
            let session = ASWebAuthenticationSession(url: authUri, callbackURLScheme: redirectUri.scheme) {
                guard let callbackUri = $0 else {
                    print("auth failed", $1 ?? "N/A")
                    completion(.failure(error: Errors.SignIn(type: .authFailed, error: $1)))
                    return
                }

                print("auth success", callbackUri)
                completion(.success)
            }

            if #available(iOS 13.0, *) {
                session.presentationContextProvider = self.authContext
                session.prefersEphemeralWebBrowserSession = true
            }

            DispatchQueue.main.async {
                session.start()
            }
        } catch let error as LogtoErrors.UrlConstruction {
            completion(.failure(error: Errors.SignIn(type: .unableToConstructAuthUri, error: error)))
        } catch {
            completion(.failure(error: Errors.SignIn(type: .unknownError, error: error)))
        }
    }

    // TO-DO: implement full functions
    func signInWithBrowser(redirectUri: String, completion: @escaping SignInCompletion) {
        guard let redirectUri = URL(string: redirectUri) else {
            completion(.failure(error: Errors.SignIn(type: .unableToConstructRedirectUri, error: nil)))
            return
        }

        fetchOidcConfig { [self] oidcConfig, error in
            guard let oidcConfig = oidcConfig else {
                completion(.failure(error: Errors.SignIn(type: .unableToFetchOidcConfig, error: error)))
                return
            }

            startSession(oidcConfig: oidcConfig, redirectUri: redirectUri, completion: completion)
        }
    }
}
