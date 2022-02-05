//
//  AccessToken.swift
//
//
//  Created by Gao Sun on 2022/1/21.
//

import Foundation

public struct AccessToken: Codable {
    let token: String
    let scope: String
    let expiresAt: TimeInterval
}
