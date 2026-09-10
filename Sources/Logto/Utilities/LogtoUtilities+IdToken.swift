//
//  LogtoUtilities+IdToken.swift
//
//
//  Created by Gao Sun on 2022/1/17.
//

import Foundation
import JOSESwift

public extension LogtoUtilities {
    /// The default clock tolerance in seconds when verifying the `iat` and `exp` claims of an ID Token.
    /// It is 5 minutes, which matches the default of the Logto JS SDK.
    static let defaultIdTokenClockTolerance: TimeInterval = 300

    /// Decode ID Token claims WITHOUT validation.
    /// - Parameter token: The JWT to decode.
    /// - Returns: A set of ID Token claims.
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

    /// Verify the given ID Token:
    /// * One of the JWKs matches the token.
    /// * Issuer matches token payload `iss`.
    /// * Client ID matches token payload `aud`.
    /// * The token is not expired, allowing the clock tolerance.
    /// * The token is issued within the clock tolerance around the given time.
    ///
    /// - Parameters:
    ///   - idToken: The ID Token in JWS compact serialization.
    ///   - issuer: The expected issuer.
    ///   - clientId: The expected audience.
    ///   - jwks: The JWK set of the OIDC provider.
    ///   - clockTolerance: The clock tolerance in seconds for the `iat` and `exp` claims, must be positive.
    ///     Defaults to `defaultIdTokenClockTolerance`.
    ///   - forTimeInterval: The time in seconds since 1970 to verify against. Defaults to now.
    /// - Throws: A `LogtoErrors.Verification` error if the verification fails.
    static func verifyIdToken(
        _ idToken: String,
        issuer: String,
        clientId: String,
        jwks: JWKSet,
        clockTolerance: TimeInterval = LogtoUtilities.defaultIdTokenClockTolerance,
        forTimeInterval: TimeInterval = Date().timeIntervalSince1970
    ) throws {
        precondition(
            clockTolerance > 0 && clockTolerance.isFinite,
            "clockTolerance must be a positive number of seconds"
        )

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
        guard TimeInterval(claims.exp) + clockTolerance > forTimeInterval else {
            throw LogtoErrors.Verification.jwtExpired
        }
        guard abs(TimeInterval(claims.iat) - forTimeInterval) <= clockTolerance else {
            throw LogtoErrors.Verification.jwtIssuedTimeIncorrect
        }
    }
}
