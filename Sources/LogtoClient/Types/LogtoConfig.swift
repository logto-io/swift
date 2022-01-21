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
    let scope: ValueOrArray<String>? = nil
    let resource: ValueOrArray<String>? = nil
    let usingPersistStorage: Bool = false
}
