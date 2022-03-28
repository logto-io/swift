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

        do {
            let config = try await LogtoCore.fetchOidcConfig(
                useSession: networkSession,
                uri: logtoConfig.endpoint.appendingPathComponent("/oidc/.well-known/openid-configuration")
            )
            oidcConfig = config
            return config
        } catch {
            throw Errors.OidcConfig(type: .unableToFetchOidcConfig, innerError: error)
        }
    }

    public func fetchUserInfo() async throws -> LogtoCore.UserInfoResponse {
        let oidcConfig = try await fetchOidcConfig()
        let token = try await getAccessToken(for: nil)

        do {
            return try await LogtoCore
                .fetchUserInfo(
                    useSession: networkSession,
                    userInfoEndpoint: oidcConfig.userinfoEndpoint,
                    accessToken: token
                )
        } catch {
            throw Errors.UserInfo(type: .unableToFetchUserInfo, innerError: error)
        }
    }
}
