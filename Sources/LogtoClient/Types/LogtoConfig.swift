//
//  LogtoConfig.swift
//
//
//  Created by Gao Sun on 2022/1/21.
//

import Foundation
import Logto

public struct LogtoConfig {
    private let _scopes: [String]

    public let endpoint: URL
    public let appId: String
    public let resources: [String]
    public let prompt: LogtoCore.Prompt
    public let usingPersistStorage: Bool

    public var scopes: [String] {
        LogtoUtilities.withReservedScopes(_scopes)
    }

    // Have to do this in Swift
    public init(
        endpoint: String,
        appId: String,
        scopes: [String] = [],
        resources: [String] = [],
        prompt: LogtoCore.Prompt = .consent,
        usingPersistStorage: Bool = true
    ) throws {
        guard let endpoint = URL(string: endpoint) else {
            throw LogtoErrors.UrlConstruction.unableToConstructUrl
        }

        self.endpoint = endpoint
        self.appId = appId
        _scopes = scopes
        self.resources = resources
        self.prompt = prompt
        self.usingPersistStorage = usingPersistStorage
    }
}
