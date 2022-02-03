//
//  LogtoClient.swift
//
//
//  Created by Gao Sun on 2022/1/21.
//

import Foundation
import Logto

public class LogtoClient {
    internal let authContext = LogtoAuthContext()
    internal let logtoConfig: LogtoConfig
    internal let networkSession: NetworkSession

    internal var accessTokenMap: [String: AccessToken] = [:]
    internal var idToken: String?
    internal var refreshToken: String?
    internal var oidcConfig: LogtoCore.OidcConfigResponse?

    internal func buildAccessTokenKey(for resource: String = "", scopes: [String]) -> String {
        "\(scopes.sorted().joined(separator: " "))@\(resource)"
    }

    public init(useConfig config: LogtoConfig, session: NetworkSession = URLSession.shared) {
        logtoConfig = config
        networkSession = session
        // TO-DO: LOG-1398 set up and use persist storage if needed
    }

    public var isAuthenticated: Bool {
        idToken != nil
    }
}
