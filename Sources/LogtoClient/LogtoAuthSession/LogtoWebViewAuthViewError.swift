//
//  LogtoWebViewAuthViewError.swift
//
//
//  Created by Gao Sun on 2022/3/29.
//

import Foundation

enum LogtoWebViewAuthViewError: LocalizedError {
    case webAuthFailed(innerError: Error?)
    case unableToConstructCallbackUri

    var code: String {
        switch self {
        case .webAuthFailed:
            return "web_auth_failed"
        case .unableToConstructCallbackUri:
            return "unable_to_construct_callback_uri"
        }
    }

    var localizedDescription: String {
        switch self {
        case let .webAuthFailed(innerError):
            return innerError?.localizedDescription ?? "Web authentication failed."
        case .unableToConstructCallbackUri:
            return "Unable to construct callback URI."
        }
    }
}
