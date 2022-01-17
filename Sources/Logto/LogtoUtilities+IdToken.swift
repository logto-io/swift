//
//  LogtoUtilities+IdToken.swift
//  
//
//  Created by Gao Sun on 2022/1/17.
//

import Foundation
import JOSESwift

extension LogtoUtilities {
    private static let idTokenTolerance: UInt64 = 60

    /// Decode ID Token claims WITHOUT validation.
    /// - Parameter token: The JWT to decode
    /// - Returns: A set of ID Token claims
    static func decodeIdToken(_ idToken: String) throws -> IdTokenClaims {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase

        let segments = idToken.split(separator: ".")

        guard let payload = segments[safe: 1] else {
            throw LogtoErrors.Decoding.noPayloadFound
        }

        guard let decoded = String.fromUrlSafeBase64(string: String(payload)) else {
            throw LogtoErrors.Decoding.invalidUrlSafeBase64Encoding
        }

        return try decoder.decode(IdTokenClaims.self, from: Data(decoded.utf8))
    }

    /// Verify the give ID Token:
    /// * One of the JWKs matches the token.
    /// * Issuer matches token payload `iss`.
    /// * Client ID matches token payload `aud`.
    /// * The token is not expired.
    /// * The token is issued in +/- 1min.
    static func verifyIdToken(
        _ idToken: String,
        issuer: String,
        clientId: String,
        jwks: JWKSet,
        forTimeInterval: TimeInterval = Date().timeIntervalSince1970
    ) throws {
        if jwks.keys.isEmpty {
            throw LogtoErrors.Verification.missingJwk
        }

        // Public key verification
        let jws = try JWS(compactSerialization: idToken)
        
        guard let algorithm = jws.header.algorithm else {
            throw LogtoErrors.Verification.jwtMissingAlgorithmInHeader
        }
        
        let verifiers: [Verifier] = try jwks
            .keys
            .compactMap({
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
            })
        
        
        guard verifiers.contains(where: {
            (try? jws.validate(using: $0)) != nil ? true : false
        }) else {
            throw LogtoErrors.Verification.noSigningKeyMatched
        }

        // Claims verification
        let claims = try decodeIdToken(idToken)
        guard claims.iss == issuer else {
            throw LogtoErrors.Verification.jwtValueMismatched(field: .issuer)
        }
        guard claims.aud == clientId else {
            throw LogtoErrors.Verification.jwtValueMismatched(field: .audience)
        }
        guard claims.exp > Int64(forTimeInterval) else {
            throw LogtoErrors.Verification.jwtExpired
        }
        guard abs(claims.iat - Int64(forTimeInterval)) <= idTokenTolerance else {
            throw LogtoErrors.Verification.jwtIssuedTimeIncorrect
        }
    }
}
