//
//  LogtoClient.swift
//
//
//  Created by Gao Sun on 2022/1/21.
//

import Foundation
import KeychainAccess
import Logto
@_exported import LogtoSocialPlugin
@_exported import LogtoSocialPluginWeb

public class LogtoClient {
    public struct NotificationObject {
        public let clientId: String?
        public let url: URL
    }

    // MARK: Static Members

    public static let HandleNotification = Notification.Name("Logto Handle")
    public static func handle(forClientId clientId: String? = nil, url: URL) {
        NotificationCenter.default.post(
            name: HandleNotification,
            object: NotificationObject(clientId: clientId, url: url)
        )
    }

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

    @discardableResult
    public func handle(url: URL) -> Bool {
        for plugin in socialPlugins {
            if plugin.handle(url: url) {
                return true
            }
        }

        return false
    }

    // MARK: Internal Functions

    func handle(notification: Notification) {
        guard let object = notification.object as? NotificationObject else {
            return
        }

        // Notification sends to all clients when `object.clientId` is nil
        guard object.clientId == nil || object.clientId == logtoConfig.clientId else {
            return
        }

        handle(url: object.url)
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

        NotificationCenter.default.addObserver(
            forName: LogtoClient.HandleNotification,
            object: nil,
            queue: nil,
            using: handle
        )
    }
}
