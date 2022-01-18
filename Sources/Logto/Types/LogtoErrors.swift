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
        case unsupportedJwkType
        case noSigningKeyMatched
        case jwtMissingAlgorithmInHeader
        case jwtExpired
        case jwtIssuedTimeIncorrect
        case jwtValueMismatched(field: JwtField)
    }

    enum UrlConstruction: LocalizedError, Equatable {
        case invalidAuthorizationEndpoint
        case unableToConstructUrl
    }
    
    enum Request: LocalizedError, Equatable {
        case noResponseData
    }
}
