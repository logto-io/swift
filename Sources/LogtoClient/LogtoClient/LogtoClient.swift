//
//  LogtoClient.swift
//
//
//  Created by Gao Sun on 2022/1/21.
//

#if os(iOS)
    import AuthenticationServices
#endif
import Foundation
import KeychainAccess
import Logto

public class LogtoClient {
    // MARK: Internal Constants

    let keychain: Keychain?
    let logtoConfig: LogtoConfig
    let networkSession: NetworkSession

    // MARK: Internal Variables

    var accessTokenMap = [String: AccessToken]()
    var isSigningIn = false
    #if os(iOS)
        var signOutAuthenticationSession: LogtoSystemAuthenticationSession?
        var signOutPresentationContextProvider: ASWebAuthenticationPresentationContextProviding?
    #endif

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

    /// Get structured [ID Token Claims](https://openid.net/specs/openid-connect-core-1_0.html#IDToken).
    /// - Throws: An error if no ID Token presents or decode token failed.
    public func getIdTokenClaims() throws -> IdTokenClaims {
        guard let idToken = idToken else {
            throw LogtoClientErrors.IdToken.notAuthenticated
        }

        return try LogtoUtilities.decodeIdToken(idToken)
    }

    // MARK: Public Init Functions

    public init(
        useConfig config: LogtoConfig,
        session: NetworkSession = URLSession.shared
    ) {
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
