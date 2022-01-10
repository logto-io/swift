//
//  LogtoUtilities.swift
//
//
//  Created by Gao Sun on 2022/1/7.
//

import CommonCrypto
import Foundation

public enum LogtoErrors {
    enum Decode: LocalizedError {
        case noPayloadFound
        case invalidUrlSafeBase64Encoding
    }
}

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
    /// - Returns: A set of ID T	oken claims
    static func decodeIdToken(_ token: String) throws -> IdTokenClaims {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        
        let segments = token.split(separator: ".")
        
        guard let payload = segments[safe: 1] else {
            throw LogtoErrors.Decode.noPayloadFound
        }
        
        guard let decoded = String.fromUrlSafeBase64(string: String(payload)) else {
            throw LogtoErrors.Decode.invalidUrlSafeBase64Encoding
        }
        
        return try decoder.decode(IdTokenClaims.self, from: Data(decoded.utf8))
    }
}
