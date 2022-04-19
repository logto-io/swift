//
//  LogtoClient+Errors.swift
//
//
//  Created by Gao Sun on 2022/1/30.
//

import Foundation

public enum LogtoClientErrors {
    public typealias AccessToken = LogtoError<LogtoClientErrorTypes.AccessToken>
    public typealias OidcConfig = LogtoError<LogtoClientErrorTypes.OidcConfig>
    public typealias UserInfo = LogtoError<LogtoClientErrorTypes.UserInfo>
    public typealias JwkSet = LogtoError<LogtoClientErrorTypes.JwkSet>
    public typealias SignIn = LogtoError<LogtoClientErrorTypes.SignIn>
    public typealias SignOut = LogtoError<LogtoClientErrorTypes.SignOut>

    public enum IdToken: String, LocalizedError {
        /// No ID Token presents in the Keychain.
        case notAuthenticated
    }
}

