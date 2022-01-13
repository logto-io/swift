//
//  LogtoErrors.swift
//
//
//  Created by Gao Sun on 2022/1/12.
//

import Foundation

public enum LogtoErrors {
    enum Decoding: LocalizedError, Equatable {
        case noPayloadFound
        case invalidUrlSafeBase64Encoding
    }

    enum Verification: LocalizedError, Equatable {
        case missingJwk
        case noPublicKeyMatched
        case tokenExpired
        case issuedTimeIncorrect
        case valueMismatch(field: JwtField)
    }
}
