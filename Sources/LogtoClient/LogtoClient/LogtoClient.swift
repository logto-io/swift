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
        public let appId: String?
        public let url: URL
    }

    // MARK: Static Members

    /// The notification name for LogtoClient to handle.
    public static let HandleNotification = Notification.Name("Logto Handle")
    /**
     Post a notification that tells Logto clients to handle the given URL.

     Usually this function need to be called in `onOpenURL(perform:)` in SwiftUI or `application(_:open:options:)` in AppDelegate. See integration guide for detailed information.

     - Parameters:
        - forAppId: If the notification is for specific App ID only. When `nil`, all Logto clients will try to handle the notification.
        - url:The URL that needs to be handled.
     */
    public static func handle(forAppId appId: String? = nil, url: URL) {
        NotificationCenter.default.post(
            name: HandleNotification,
            object: NotificationObject(appId: appId, url: url)
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

    /// The cached ID Token in raw string.
    /// Use `.getIdTokenClaims()` to retrieve structured data.
    public internal(set) var idToken: String? {
        didSet { saveToKeychain(forKey: .idToken) }
    }

    /// The cached Refresh Token.
    public internal(set) var refreshToken: String? {
        didSet { saveToKeychain(forKey: .refreshToken) }
    }

    /// The config fetched from [OIDC Discovery](https://openid.net/specs/openid-connect-discovery-1_0.html) endpoint.
    public internal(set) var oidcConfig: LogtoCore.OidcConfigResponse?

    // MARK: Public Computed Variables

    /// Whether the user has been authenticated.
    public var isAuthenticated: Bool {
        idToken != nil
    }

    // MARK: Public Functions

    /// Get structured [ID Token Claims](https://openid.net/specs/openid-connect-core-1_0.html#IDToken).
    /// - Throws: An error if no ID Token presents or decode token failed.
    public func getIdTokenClaims() throws -> IdTokenClaims {
        guard let idToken = idToken else {
            throw LogtoClientErrors.IdToken.notAuthenticated
        }

        return try LogtoUtilities.decodeIdToken(idToken)
    }

    /**
     Try to handle the given URL by iterating all social plugins.

     The iteration stops when one of the social plugins handled the URL.

     - Returns: `true` if one of the social plugins handled this URL.
     */
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

        // Notification sends to all clients when `object.appId` is nil
        guard object.appId == nil || object.appId == logtoConfig.appId else {
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
