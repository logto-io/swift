//
//  LogtoClient+SignOut.swift
//
//
//  Created by Gao Sun on 2022/2/4.
//

import Foundation
import Logto

public extension LogtoClient {
    func signOut(completion: LogtoCompletion<Errors.SignOut>? = nil) {
        if let refreshToken = refreshToken {
            fetchOidcConfig { [self] oidcConfig, error in
                guard let oidcConfig = oidcConfig else {
                    completion?(.failure(error: Errors.SignOut(type: .unableToFetchOidcConfig, innerError: error)))
                    return
                }

                LogtoCore.revoke(
                    token: refreshToken,
                    revocationEndpoint: oidcConfig.revocationEndpoint,
                    clientId: logtoConfig.clientId
                ) {
                    guard $0 == nil else {
                        completion?(.failure(error: Errors.SignOut(type: .unableToRevokeToken, innerError: $0)))
                        return
                    }

                    completion?(.success)
                }
            }
        }

        accessTokenMap.clear()
        refreshToken = nil
        idToken = nil
    }
}
