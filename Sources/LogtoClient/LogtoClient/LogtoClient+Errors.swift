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
                case noRefreshTokenFound
                case unableToFetchTokenByRefreshToken
            }

            public let type: AccessTokenError
            public let innerError: Error?
        }

        public struct OidcConfig: LogtoError, LocalizedError {
            public enum OidcConfigError {
                case unableToFetchOidcConfig
            }

            public let type: OidcConfigError
            public let innerError: Error?
        }

        public struct UserInfo: LogtoError, LocalizedError {
            public enum UserInfoError {
                case unableToFetchUserInfo
            }

            public let type: UserInfoError
            public let innerError: Error?
        }

        public enum IdToken: String, LocalizedError {
            case notAuthenticated
        }

        public struct SignIn: LogtoError {
            public enum SignInError: String {
                case unknownError
                case authFailed
                case unableToConstructRedirectUri
                case unableToConstructAuthUri
                case unableToFetchToken
                case unexpectedSignInCallback
            }

            public let type: SignInError
            public let innerError: Error?
        }

        public struct SignOut: LogtoError {
            public enum SignOutError: String {
                case unableToRevokeToken
            }

            public let type: SignOutError
            public let innerError: Error?
        }
    }
}
