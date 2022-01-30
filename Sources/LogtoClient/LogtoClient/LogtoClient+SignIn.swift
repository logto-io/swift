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
    internal func fetchOidcConfig(completion: @escaping HttpCompletion<LogtoCore.OidcConfigResponse>) {
        guard oidcConfig == nil else {
            completion(oidcConfig, nil)
            return
        }

        let requestCompletion: HttpCompletion<LogtoCore.OidcConfigResponse> = { config, error in
            if error != nil || config == nil {
                completion(nil, error ?? LogtoClientErrors.Fetch.unableToFetchOidcConfig)
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

    // TO-DO: error handling
    // TO-DO: implement full functions
    func signInWithBrowser() {
        fetchOidcConfig { [self] oidcConfig, _ in
            guard let oidcConfig = oidcConfig else {
                return
            }

            let scheme = "io.logto.SwiftUI-Demo"
            let state = LogtoUtilities.generateState()
            let codeVerifier = LogtoUtilities.generateCodeVerifier()
            let codeChallenge = LogtoUtilities.generateCodeChallenge(codeVerifier: codeVerifier)

            guard let authUri = try? LogtoCore.generateSignInUri(
                authorizationEndpoint: oidcConfig.authorizationEndpoint,
                clientId: logtoConfig.clientId,
                redirectUri: "\(scheme)://callback",
                codeChallenge: codeChallenge,
                state: state,
                scope: nil,
                resource: nil
            ) else {
                return
            }

            let session = ASWebAuthenticationSession(url: authUri, callbackURLScheme: scheme) {
                print("result", $0 ?? "N/A", $1 ?? "N/A")
            }

            if #available(iOS 13.0, *) {
                session.presentationContextProvider = self.authContext
                session.prefersEphemeralWebBrowserSession = true
            }

            DispatchQueue.main.async {
                session.start()
            }
        }
    }
}
