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
    public let clientId: String
    public let resources: [String]
    public let usingPersistStorage: Bool

    public var scopes: [String] {
        LogtoUtilities.withReservedScopes(_scopes)
    }

    // Have to do this in Swift
    public init(
        endpoint: String,
        clientId: String,
        scopes: [String] = [],
        resources: [String] = [],
        usingPersistStorage: Bool = true
    ) throws {
        guard let endpoint = URL(string: endpoint) else {
            throw LogtoErrors.UrlConstruction.unableToConstructUrl
        }

        self.endpoint = endpoint
        self.clientId = clientId
        _scopes = scopes
        self.resources = resources
        self.usingPersistStorage = usingPersistStorage
    }
}
