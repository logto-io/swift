//
//  LogtoClient.swift
//
//
//  Created by Gao Sun on 2022/1/21.
//

import Foundation
import KeychainAccess
import Logto
import LogtoSocialPlugin
import LogtoSocialPluginWeb

public class LogtoClient {
    // MARK: Internal Constants

    internal let authContext = LogtoAuthContext()
    internal let keychain: Keychain?
    internal let logtoConfig: LogtoConfig
    internal let networkSession: NetworkSession
    internal let socialPlugins: [LogtoSocialPlugin]

    // MARK: Internal Variables

    internal var accessTokenMap = [String: AccessToken]()
    internal var getAccessTokenTaskMap = [String: Task<String, Error>]()

    // MARK: Public Variables

    public internal(set) var idToken: String? {
        didSet { saveToKeychain(forKey: .idToken) }
    }

    public internal(set) var refreshToken: String? {
        didSet { saveToKeychain(forKey: .refreshToken) }
    }

    public internal(set) var oidcConfig: LogtoCore.OidcConfigResponse?

    // MARK: Public Computed Variables

    public var isAuthenticated: Bool {
        idToken != nil
    }

    // MARK: Public Functions

    public func getIdTokenClaims() throws -> IdTokenClaims {
        guard let idToken = idToken else {
            throw Errors.IdToken.notAuthenticated
        }

        return try LogtoUtilities.decodeIdToken(idToken)
    }

    // MARK: Public Init Functions

    public init(
        useConfig config: LogtoConfig,
        socialPlugins: [LogtoSocialPlugin] = [],
        session: NetworkSession = URLSession.shared
    ) {
        logtoConfig = config
        networkSession = session
        self.socialPlugins = [LogtoSocialPluginWeb()] + socialPlugins

        if config.usingPersistStorage {
            keychain = Keychain(service: LogtoClient.keychainServiceName)
            loadFromKeychain()
        } else {
            keychain = nil
        }
    }
}
