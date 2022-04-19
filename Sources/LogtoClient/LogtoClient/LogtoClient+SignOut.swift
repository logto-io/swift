//
//  LogtoClient+SignOut.swift
//
//
//  Created by Gao Sun on 2022/2/4.
//

import Foundation
import Logto

public extension LogtoClient {
    /**
     Clear all tokens in memory and Keychain. Also try to revoke the Refresh Token from the OIDC provider.

     - Returns: An error if failed to revoke the token. Usually the error is safe to ignore.
     */
    @discardableResult
    func signOut() async -> LogtoClientErrors.SignOut? {
        let tokenToRevoke = refreshToken

        accessTokenMap = [:]
        refreshToken = nil
        idToken = nil

        if let token = tokenToRevoke {
            do {
                let oidcConfig = try await fetchOidcConfig()
                try await LogtoCore.revoke(
                    useSession: networkSession,
                    token: token,
                    revocationEndpoint: oidcConfig.revocationEndpoint,
                    clientId: logtoConfig.clientId
                )
                return nil
            } catch {
                return (LogtoClientErrors.SignOut(type: .unableToRevokeToken, innerError: error))
            }
        }

        return nil
    }
}
