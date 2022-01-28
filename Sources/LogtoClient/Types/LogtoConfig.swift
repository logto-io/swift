//
//  LogtoConfig.swift
//
//
//  Created by Gao Sun on 2022/1/21.
//

import Foundation
import Logto

public struct LogtoConfig {
    private let _scope: ValueOrArray<String>?

    let endpoint: URL
    let clientId: String
    let resource: ValueOrArray<String>?
    let usingPersistStorage: Bool

    var scope: [String] {
        LogtoUtilities.withReservedScopes(_scope)
    }

    // Have to do this in Swift
    init(
        endpoint: String,
        clientId: String,
        scope: ValueOrArray<String>? = nil,
        resource: ValueOrArray<String>? = nil,
        usingPersistStorage: Bool = false
    ) throws {
        guard let endpoint = URL(string: endpoint) else {
            throw LogtoErrors.UrlConstruction.unableToConstructUrl
        }

        self.endpoint = endpoint
        self.clientId = clientId
        _scope = scope
        self.resource = resource
        self.usingPersistStorage = usingPersistStorage
    }
}
