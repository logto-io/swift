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
    private let _resources: [String]

    public let endpoint: URL
    public let appId: String
    public let prompt: LogtoCore.Prompt
    public let usingPersistStorage: Bool

    public var scopes: [String] {
        LogtoUtilities.withReservedScopes(_scopes)
    }

    public var resources: [String] {
        scopes.contains(UserScope.organizations.rawValue)
            ? _resources + [ReservedResource.organizations.rawValue]
            : _resources
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
        _resources = resources
        self.prompt = prompt
        self.usingPersistStorage = usingPersistStorage
    }
}
