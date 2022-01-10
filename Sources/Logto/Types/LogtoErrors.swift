//
//  LogtoErrors.swift
//
//
<<<<<<< HEAD
//  Created by Gao Sun on 2022/1/12.
=======
//  Created by Gao Sun on 2022/1/10.
>>>>>>> d7aa8f7 (feat: `verifyIdToken()`)
//

import Foundation

public enum LogtoErrors {
<<<<<<< HEAD
    enum Decode: LocalizedError {
        case noPayloadFound
        case invalidUrlSafeBase64Encoding
    }
=======
    enum Decoding: LocalizedError {
        case noPayloadFound
        case invalidUrlSafeBase64Encoding
    }

    enum Verification: LocalizedError {
        case missingJwt
        case noPublicKeyMatched
        case tokenExpired
        case issuedTimeIncorrect
        case valueMismatch(field: JwtField)
    }
>>>>>>> d7aa8f7 (feat: `verifyIdToken()`)
}
