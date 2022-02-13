//
//  LogtoClient+SignOut.swift
//
//
//  Created by Gao Sun on 2022/2/4.
//

import Foundation
import Logto

public extension LogtoClient {
    func signOut(completion: EmptyCompletion<Errors.SignOut>? = nil) {
        let tokenToRevoke = refreshToken

        accessTokenMap = [:]
        refreshToken = nil
        idToken = nil

        if let token = tokenToRevoke {
            fetchOidcConfig { [self] oidcConfig, error in
                guard let oidcConfig = oidcConfig else {
                    completion?(Errors.SignOut(type: .unableToFetchOidcConfig, innerError: error))
                    return
                }

                LogtoCore.revoke(
                    useSession: networkSession,
                    token: token,
                    revocationEndpoint: oidcConfig.revocationEndpoint,
                    clientId: logtoConfig.clientId
                ) {
                    guard $0 == nil else {
                        completion?(Errors.SignOut(type: .unableToRevokeToken, innerError: $0))
                        return
                    }

                    completion?(nil)
                }
            }
        }
    }
}
