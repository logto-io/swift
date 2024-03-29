//
//  IdTokenClaims.swift
//
//
//  Created by Gao Sun on 2022/1/7.
//

import Foundation

public struct IdTokenClaims: UserInfoProtocol {
    public let sub: String
    public let atHash: String?
    public let aud: String
    public let exp: Int64
    public let iat: Int64
    public let iss: String

    // Protocol
    public let name: String?
    public let picture: String?
    public let username: String?
    public let email: String?
    public let emailVerified: Bool?
    public let phoneNumber: String?
    public let phoneNumberVerified: Bool?
    public let roles: [String]?
    public let organizations: [String]?
    public let organizationRoles: [String]?
}
