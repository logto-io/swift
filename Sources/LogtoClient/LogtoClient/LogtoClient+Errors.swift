//
//  LogtoClient+Errors.swift
//
//
//  Created by Gao Sun on 2022/1/30.
//

import Foundation

public extension LogtoClient {
    enum Errors {
        public enum Fetch: String, LocalizedError {
            case unableToFetchOidcConfig
        }

        public enum IdToken: String, LocalizedError {
            case notAuthenticated
        }

        public struct SignIn: LocalizedError {
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
    }
}
