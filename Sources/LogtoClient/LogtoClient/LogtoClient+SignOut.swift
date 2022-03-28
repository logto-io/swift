//
//  LogtoClient+SignOut.swift
//
//
//  Created by Gao Sun on 2022/2/4.
//

import Foundation
import Logto

public extension LogtoClient {
    @discardableResult
    func signOut() async throws -> Errors.SignOut? {
        let tokenToRevoke = refreshToken

        accessTokenMap = [:]
        refreshToken = nil
        idToken = nil

        if let token = tokenToRevoke {
            let oidcConfig = try await fetchOidcConfig()

            do {
                try await LogtoCore.revoke(
                    useSession: networkSession,
                    token: token,
                    revocationEndpoint: oidcConfig.revocationEndpoint,
                    clientId: logtoConfig.clientId
                )
                return nil
            } catch {
                return (Errors.SignOut(type: .unableToRevokeToken, innerError: error))
            }
        }

        return nil
    }
}
