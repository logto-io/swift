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
    static func getCamelCaseDecoder() -> JSONDecoder {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return decoder
    }

    public enum Scope: String, CaseIterable {
        case openid
        case offlineAccess = "offline_access"
        case profile
    }

    public static let reservedScopes = Scope.allCases

    public static func withReservedScopes(_ scopes: [String]) -> [String] {
        Array(Set(scopes + reservedScopes.map { $0.rawValue }))
    }

    public static func generateState() -> String {
        Data.randomArray(length: 64).toUrlSafeBase64String()
    }

    public static func generateCodeVerifier() -> String {
        Data.randomArray(length: 64).toUrlSafeBase64String()
    }

    public static func generateCodeChallenge(codeVerifier: String) -> String {
        let data = Data(codeVerifier.utf8)
        var hash = [UInt8](repeating: 0, count: Int(CC_SHA256_DIGEST_LENGTH))
        data.withUnsafeBytes {
            _ = CC_SHA256($0.baseAddress, CC_LONG(data.count), &hash)
        }
        return Data(hash).toUrlSafeBase64String()
    }
}
