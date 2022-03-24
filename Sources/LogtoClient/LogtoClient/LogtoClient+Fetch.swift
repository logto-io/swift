//
//  LogtoClient+Fetch.swift
//
//
//  Created by Gao Sun on 2022/2/5.
//

import Foundation
import Logto

extension LogtoClient {
    internal func fetchOidcConfig() async throws -> LogtoCore.OidcConfigResponse {
        if let config = oidcConfig {
            return config
        }

        return try await withCheckedThrowingContinuation { continuation in
            let completion: Completion<LogtoCore.OidcConfigResponse, Error> = { config, error in
                guard error == nil, let config = config else {
                    continuation.resume(throwing: Errors.OidcConfig(type: .unableToFetchOidcConfig, innerError: error))
                    return
                }

                self.oidcConfig = config
                continuation.resume(returning: config)
            }

            LogtoRequest.get(
                useSession: networkSession,
                url: logtoConfig.endpoint.appendingPathComponent("/oidc/.well-known/openid-configuration"),
                completion: completion
            )
        }
    }

    public func fetchUserInfo() async throws -> LogtoCore.UserInfoResponse {
        let oidcConfig = try await fetchOidcConfig()
        let token = try await getAccessToken(for: nil)

        return try await withCheckedThrowingContinuation { continuation in
            LogtoCore
                .fetchUserInfo(
                    useSession: self.networkSession,
                    userInfoEndpoint: oidcConfig.userinfoEndpoint,
                    accessToken: token
                ) { userInfo, error in
                    guard let userInfo = userInfo else {
                        continuation.resume(throwing: Errors.UserInfo(type: .unableToFetchUserInfo, innerError: error))
                        return
                    }

                    continuation.resume(returning: userInfo)
                }
        }
    }
}
