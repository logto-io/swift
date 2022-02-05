//
//  LogtoClient+Errors.swift
//
//
//  Created by Gao Sun on 2022/1/30.
//

import Foundation

public extension LogtoClient {
    enum Errors {
        public struct Fetch: LogtoError, LocalizedError {
            public enum FetchError {
                case unableToFetchOidcConfig
                case unableToFetchUserInfo
            }

            public let type: FetchError
            public let innerError: Error?
        }

        public enum IdToken: String, LocalizedError {
            case notAuthenticated
        }

        public struct SignIn: LogtoError {
            public enum SignInError: String {
                case unknownError
                case authFailed
                case unableToFetchOidcConfig
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
                case unableToFetchOidcConfig
            }

            public let type: SignOutError
            public let innerError: Error?
        }
    }
}
