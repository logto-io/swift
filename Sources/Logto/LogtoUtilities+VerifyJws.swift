//
//  LogtoUtilities+VerifyJws.swift
//  
//
//  Created by Gao Sun on 2022/1/18.
//

import Foundation
import JOSESwift

extension LogtoUtilities {
    static func verifyJws(
        _ jws: JWS,
        jwks: JWKSet
    ) throws {
        if jwks.keys.isEmpty {
            throw LogtoErrors.Verification.missingJwk
        }

        guard let algorithm = jws.header.algorithm else {
            throw LogtoErrors.Verification.jwtMissingAlgorithmInHeader
        }

        let verifiers: [Verifier] = try jwks
            .keys
            .compactMap {
                // [RFC-7518](https://tools.ietf.org/html/rfc7518#section-7.4)
                switch $0 {
                case let publicKey as ECPublicKey:
                    if let secKey = try? publicKey.converted(to: SecKey.self) {
                        return Verifier(verifyingAlgorithm: algorithm, key: secKey)
                    }
                case let publicKey as RSAPublicKey:
                    if let secKey = try? publicKey.converted(to: SecKey.self) {
                        return Verifier(verifyingAlgorithm: algorithm, key: secKey)
                    }
                case let symmetricKey as SymmetricKey:
                    if let data = try? symmetricKey.converted(to: Data.self) {
                        return Verifier(verifyingAlgorithm: algorithm, key: data)
                    }
                default:
                    throw LogtoErrors.Verification.unsupportedJwkType
                }
                return nil
            }

        guard verifiers.contains(where: {
            (try? jws.validate(using: $0)) != nil ? true : false
        }) else {
            throw LogtoErrors.Verification.noSigningKeyMatched
        }
    }
}
