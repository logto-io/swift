//
//  LogtoUtilities+IdToken.swift
//
//
//  Created by Gao Sun on 2022/1/17.
//

import Foundation
import JOSESwift

public extension LogtoUtilities {
    private static let idTokenTolerance: Int64 = 60

    /// Decode ID Token claims WITHOUT validation.
    /// - Parameter token: The JWT to decode
    /// - Returns: A set of ID Token claims
    static func decodeIdToken(_ idToken: String) throws -> IdTokenClaims {
        let decoder = LogtoUtilities.getCamelCaseDecoder()

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
        try verifyJws(jws, jwks: jwks)

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
