//
//  LogtoClient+Fetch.swift
//
//
//  Created by Gao Sun on 2022/2/5.
//

import Foundation
import Logto

extension LogtoClient {
    internal func fetchOidcConfig(completion: @escaping HttpCompletion<LogtoCore.OidcConfigResponse>) {
        guard oidcConfig == nil else {
            completion(oidcConfig, nil)
            return
        }

        let requestCompletion: HttpCompletion<LogtoCore.OidcConfigResponse> = { config, error in
            if error != nil || config == nil {
                completion(nil, error ?? Errors.Fetch(type: .unableToFetchOidcConfig, innerError: nil))
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

    public func fetchUserInfo(completion: @escaping Completion<LogtoCore.UserInfoResponse, Errors.Fetch>) {
        fetchOidcConfig { [self] oidcConfig, error in
            guard let oidcConfig = oidcConfig else {
                completion(nil, Errors.Fetch(type: .unableToFetchOidcConfig, innerError: error))
                return
            }

            // TO-DO: Use `.getAccessToken()`
            let token = accessTokenMap[buildAccessTokenKey(scopes: [])]?.token ?? ""
            LogtoCore
                .fetchUserInfo(userInfoEndpoint: oidcConfig.userinfoEndpoint, accessToken: token) { userInfo, error in
                    guard let userInfo = userInfo else {
                        completion(nil, Errors.Fetch(type: .unableToFetchUserInfo, innerError: error))
                        return
                    }

                    completion(userInfo, nil)
                }
        }
    }
}
