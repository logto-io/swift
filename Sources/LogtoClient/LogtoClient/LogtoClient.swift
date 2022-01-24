//
//  LogtoClient.swift
//
//
//  Created by Gao Sun on 2022/1/21.
//

import Foundation
import Logto

public class LogtoClient {
    internal let accessTokenMap: [String: AccessToken] = [:]
    internal let logtoConfig: LogtoConfig

    internal var idToken: String?
    internal var refreshToken: String?
    internal var oidcConfig: LogtoCore.OidcConfigResponse?

    init(useConfig config: LogtoConfig) {
        logtoConfig = config
        // TO-DO: LOG-1398 set up and use persist storage if needed
    }
    
    var isAuthenticated: Boolean {
        idToken != nil
    }
}
