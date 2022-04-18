//
//  LogtoSocialPluginError.swift
//
//
//  Created by Gao Sun on 2022/4/1.
//

import Foundation

public enum LogtoSocialPluginError: LocalizedError {
    case authenticationFailed(socialCode: String?, socialMessage: String?)
    case invalidRedirectTo
    case invalidCallbackUri
    case unableToConstructCallbackUri
    case insufficientInformation

    public var code: String {
        switch self {
        case .authenticationFailed:
            return "authentication_failed"
        case .invalidRedirectTo:
            return "invalid_redirect_to"
        case .invalidCallbackUri:
            return "invalid_callback_uri"
        case .unableToConstructCallbackUri:
            return "unable_to_construct_callback_uri"
        case .insufficientInformation:
            return "insufficient_information"
        }
    }
}
