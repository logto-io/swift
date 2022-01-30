//
//  File.swift
//
//
//  Created by Gao Sun on 2022/1/30.
//

import Foundation

public extension LogtoClient {
    enum Errors {
        public enum Fetch: LocalizedError {
            case unableToFetchOidcConfig
        }

        public struct SignIn: LocalizedError {
            enum SignInError {
                case unknownError
                case unableToFetchOidcConfig
                case unableToConstructRedirectUri
                case unableToConstructAuthUri
                case authFailed
            }

            let type: SignInError
            let error: Error?
        }
    }
}
