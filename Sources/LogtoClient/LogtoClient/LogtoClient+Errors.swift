//
//  LogtoClient+Errors.swift
//
//
//  Created by Gao Sun on 2022/1/30.
//

import Foundation

public extension LogtoClient {
    enum Errors {
        public struct AccessToken: LogtoError, LocalizedError {
            public enum AccessTokenError {
                /// No Refresh Token presents in the Keychain.
                case noRefreshTokenFound
                /// Unable to use Refresh Token to fetch a new Access Token.
                /// The Refresh Token could be expired or revoked.
                case unableToFetchTokenByRefreshToken
            }

            public let type: AccessTokenError
            public let innerError: Error?
        }

        public struct OidcConfig: LogtoError, LocalizedError {
            public enum OidcConfigError {
                /// Unable to fetch OIDC config from the OIDC provider.
                case unableToFetchOidcConfig
            }

            public let type: OidcConfigError
            public let innerError: Error?
        }

        public struct UserInfo: LogtoError, LocalizedError {
            public enum UserInfoError {
                /// Unable to fetch user info from the OIDC provider.
                case unableToFetchUserInfo
            }

            public let type: UserInfoError
            public let innerError: Error?
        }

        public struct JwkSet: LogtoError, LocalizedError {
            public enum JwtSetError {
                /// Unable to fetch JWK set from the given URI.
                case unableToFetchJwkSet
            }

            public let type: JwtSetError
            public let innerError: Error?
        }

        public enum IdToken: String, LocalizedError {
            /// No ID Token presents in the Keychain.
            case notAuthenticated
        }

        public struct SignIn: LogtoError {
            public enum SignInError: String {
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

            public let type: SignInError
            public let innerError: Error?
        }

        public struct SignOut: LogtoError {
            public enum SignOutError: String {
                /// Unable to revoke token in the OIDC provider.
                /// Usually this error is safe to ignore.
                case unableToRevokeToken
            }

            public let type: SignOutError
            public let innerError: Error?
        }
    }
}
