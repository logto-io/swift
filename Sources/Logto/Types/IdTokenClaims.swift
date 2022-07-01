//
//  IdTokenClaims.swift
//
//
//  Created by Gao Sun on 2022/1/7.
//

import Foundation

public struct IdTokenClaims: Codable, Equatable {
    public let sub: String
    public let atHash: String?
    public let aud: String
    public let exp: Int64
    public let iat: Int64
    public let iss: String
    
    // Scope `profile`
    public let name: String?
    public let username: String?
    public let avatar: String?
    public let roleNames: [String]?
}
