//
//  LogtoClient.swift
//
//
//  Created by Gao Sun on 2022/1/21.
//

import Foundation
import KeychainAccess
import Logto

public class LogtoClient {
    // MARK: Internal Constants

    internal let authContext = LogtoAuthContext()
    internal let keychain: Keychain?
    internal let logtoConfig: LogtoConfig
    internal let networkSession: NetworkSession

    // MARK: Internal Variables

    internal var accessTokenMap: [String: AccessToken] = [:] {
        didSet { saveToKeychain(forKey: .accessTokenMap) }
    }

    // MARK: Public Variables

    public internal(set) var idToken: String? {
        didSet { saveToKeychain(forKey: .idToken) }
    }

    public internal(set) var refreshToken: String? {
        didSet { saveToKeychain(forKey: .refreshToken) }
    }

    public internal(set) var oidcConfig: LogtoCore.OidcConfigResponse?

    // MARK: Internal Functions

    internal func buildAccessTokenKey(for resource: String = "", scopes: [String]) -> String {
        "\(scopes.sorted().joined(separator: " "))@\(resource)"
    }

    // MARK: Public Computed Variables

    public var isAuthenticated: Bool {
        idToken != nil
    }

    // MARK: Public Init Functions

    public init(useConfig config: LogtoConfig, session: NetworkSession = URLSession.shared) {
        logtoConfig = config
        networkSession = session

        if config.usingPersistStorage {
            keychain = Keychain(service: LogtoClient.keychainServiceName)
            loadFromKeychain()
        } else {
            keychain = nil
        }
    }
}
