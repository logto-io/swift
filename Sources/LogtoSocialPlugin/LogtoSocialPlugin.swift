//
//  LogtoSocialPlugin.swift
//
//
//  Created by Gao Sun on 2022/3/30.
//

import Foundation

public struct LogtoSocialPluginConfiguration {
    public let redirectUri: URL
    public let callbackUri: URL
    public let completion: (URL) -> Void
    public let errorHandler: (LogtoSocialPluginError) -> Void

    // https://stackoverflow.com/a/54673401/12514940
    public init(
        redirectUri: URL,
        callbackUri: URL,
        completion: @escaping (URL) -> Void,
        errorHandler: @escaping (LogtoSocialPluginError) -> Void
    ) {
        self.redirectUri = redirectUri
        self.callbackUri = callbackUri
        self.completion = completion
        self.errorHandler = errorHandler
    }
}

public protocol LogtoSocialPlugin {
    var connectorId: String { get }
    var urlSchemes: [String] { get }
    var isAvailable: Bool { get }

    func handle(url: URL) -> Bool
    func start(_ configuration: LogtoSocialPluginConfiguration)
}

public extension LogtoSocialPlugin {
    var isAvailable: Bool {
        true
    }

    func handle(url _: URL) -> Bool {
        false
    }
}
