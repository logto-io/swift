//
//  LogtoClient+SignOut.swift
//
//
//  Created by Gao Sun on 2022/2/4.
//

import Foundation
import Logto

public extension LogtoClient {
    func signOut(completion: EmptyCompletion<Errors.SignOut>? = nil) async throws {
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
                completion?(nil)
            } catch {
                completion?(Errors.SignOut(type: .unableToRevokeToken, innerError: error))
            }
        }
    }
}
