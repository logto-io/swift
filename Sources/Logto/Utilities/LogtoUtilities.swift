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
    static let reservedScopes = ["openid", "offline_access"]

    public static func withReservedScopes(_ scopes: ValueOrArray<String>?) -> [String] {
        Array(Set((scopes?.inArray ?? []) + reservedScopes)).sorted()
    }

    public static func generateState() -> String {
        Data.randomArray(length: 64).toUrlSafeBase64String()
    }

    public static func generateCodeVerifier() -> String {
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
}
