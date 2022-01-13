//
//  LogtoUtilities.swift
//
//
//  Created by Gao Sun on 2022/1/7.
//

import CommonCrypto
import Foundation
import JOSESwift

public enum LogtoUtilities {
    static func generateState() -> String {
        Data.randomArray(length: 64).toUrlSafeBase64String()
    }

    static func generateCodeVerifier() -> String {
        Data.randomArray(length: 64).toUrlSafeBase64String()
    }

    static func generateCodeChallenge(codeVerifier: String) -> String {
        let data = Data(codeVerifier.utf8)
        var hash = [UInt8](repeating: 0, count: Int(CC_SHA256_DIGEST_LENGTH))
        data.withUnsafeBytes {
            _ = CC_SHA256($0.baseAddress, CC_LONG(data.count), &hash)
        }
        return Data(hash).toUrlSafeBase64String()
    }

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
        publicKeys: [RSAPublicKey],
        forTimeInterval: TimeInterval = Date().timeIntervalSince1970
    ) throws {
        if publicKeys.isEmpty {
            throw LogtoErrors.Verification.missingJwk
        }

        // Public key verification
        let jws = try JWS(compactSerialization: idToken)
        guard publicKeys
            .compactMap({ try? $0.converted(to: SecKey.self) })
            .compactMap({ Verifier(verifyingAlgorithm: .RS256, key: $0) })
            .contains(where: {
                (try? jws.validate(using: $0)) != nil ? true : false
            })
        else {
            throw LogtoErrors.Verification.noPublicKeyMatched
        }

        // Claims verification
        let claims = try decodeIdToken(idToken)
        guard claims.iss == issuer else {
            throw LogtoErrors.Verification.valueMismatch(field: .issuer)
        }
        guard claims.aud == clientId else {
            throw LogtoErrors.Verification.valueMismatch(field: .audience)
        }
        guard claims.exp > Int64(forTimeInterval / 1000) else {
            throw LogtoErrors.Verification.tokenExpired
        }
        guard abs(claims.iat - Int64(forTimeInterval / 1000)) <= 60 else {
            throw LogtoErrors.Verification.issuedTimeIncorrect
        }
    }
}
