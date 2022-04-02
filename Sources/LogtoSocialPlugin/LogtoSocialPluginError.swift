//
//  LogtoSocialPluginError.swift
//
//
//  Created by Gao Sun on 2022/4/1.
//

import Foundation

public protocol LogtoSocialPluginError: LocalizedError {
    var code: String { get }
}

public enum LogtoSocialPluginUriError: LogtoSocialPluginError {
    case unableToConstructRedirectComponents
    case unableToConstructCallbackComponents
    case unableToConstructCallbackUri

    public var code: String {
        switch self {
        case .unableToConstructRedirectComponents:
            return "unable_to_construct_redirect_components"
        case .unableToConstructCallbackComponents:
            return "unable_to_construct_callback_components"
        case .unableToConstructCallbackUri:
            return "unable_to_construct_callback_uri"
        }
    }

    var localizedDescription: String {
        switch self {
        case .unableToConstructRedirectComponents:
            return "Unable to construct redirect components."
        case .unableToConstructCallbackComponents:
            return "Unable to construct callback components."
        case .unableToConstructCallbackUri:
            return "Unable to construct callback URI."
        }
    }
}
