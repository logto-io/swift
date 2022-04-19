//
//  AccessToken.swift
//
//
//  Created by Gao Sun on 2022/1/21.
//

import Foundation

public struct AccessToken: Codable {
    public let token: String
    public let scope: String
    public let expiresAt: TimeInterval
}
