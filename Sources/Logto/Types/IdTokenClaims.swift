//
//  IdTokenClaims.swift
//
//
//  Created by Gao Sun on 2022/1/7.
//

import Foundation

public struct IdTokenClaims {
    let sub: String
    let atHash: String
    let aud: String
    let exp: Int64
    let iat: Int64
    let iss: String
}
