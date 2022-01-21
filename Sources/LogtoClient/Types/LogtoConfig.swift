//
//  LogtoConfig.swift
//
//
//  Created by Gao Sun on 2022/1/21.
//

import Foundation
import Logto

public struct LogtoConfig {
    let endpoint: String
    let clientId: String
    let scope: ValueOrArray<String>?
    let resource: ValueOrArray<String>?
    let usingPersistStorage: Bool
    
    var computedScopes: [String] {
        LogtoUtilities.withReservedScopes(scope)
    }
    
    // Have to do this in Swift
    init(endpoint: String, clientId: String, scope: ValueOrArray<String>? = nil, resource: ValueOrArray<String>? = nil, usingPersistStorage: Bool = false) {
        self.endpoint = endpoint
        self.clientId = clientId
        self.scope = scope
        self.resource = resource
        self.usingPersistStorage = usingPersistStorage
    }
}
