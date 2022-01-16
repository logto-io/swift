//
//  JWK.swift
//
//
//  Created by Gao Sun on 2022/1/10.
//

import Foundation
import JOSESwift

public struct JwtHeader: Codable {
    enum TokenType: String, Codable {
        case JWT
    }

    let alg: SignatureAlgorithm
    let typ: TokenType
}

public enum JwtField {
    case audience
    case issuer
}
