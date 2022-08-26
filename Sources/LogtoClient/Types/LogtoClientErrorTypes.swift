//
//  LogtoClientErrorTypes.swift
//
//
//  Created by Gao Sun on 2022/4/18.
//

import Foundation

public enum LogtoClientErrorTypes {
    public enum AccessToken {
        /// No Refresh Token presents in the Keychain.
        case noRefreshTokenFound
        /// Unable to use Refresh Token to fetch a new Access Token.
        /// The Refresh Token could be expired or revoked.
        case unableToFetchTokenByRefreshToken
    }

    public enum OidcConfig {
        /// Unable to fetch OIDC config from the OIDC provider.
        case unableToFetchOidcConfig
    }

    public enum UserInfo {
        /// Unable to fetch user info from the OIDC provider.
        case unableToFetchUserInfo
    }

    public enum JwkSet {
        /// Unable to fetch JWK set from the given URI.
        case unableToFetchJwkSet
    }

    public enum SignIn: String {
        case unknownError
        /// Failed to complete the authentication.
        /// This could be an internal error or the user canceled the authentication.
        case authFailed
        /// Unable to construct Redirect URI for the given string.
        case unableToConstructRedirectUri
        /// Unable to construct Redirect URI for the config.
        /// Please double check OIDC and Logto config.
        case unableToConstructAuthUri
        /// Unable to finish the initial token request after authentication.
        case unableToFetchToken
        /// The sign in callback URI is not valid.
        case unexpectedSignInCallback
    }

    public enum SignOut: String {
        /// Unable to revoke token in the OIDC provider.
        /// Usually this error is safe to ignore.
        case unableToRevokeToken
    }
}
