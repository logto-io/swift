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

    public static let reservedScopes = [UserScope.openid, UserScope.offlineAccess, UserScope.profile]

    public static func withReservedScopes(_ scopes: [String]) -> [String] {
        Array(Set(scopes + reservedScopes.map { $0.rawValue }))
    }

    /// The prefix for Logto organization URNs.
    public static let organizationUrnPrefix = "urn:logto:organization:"

    /// Build the organization URN from the organization ID.
    ///
    /// # Examlpe #
    /// ```swift
    /// buildOrganizationUrn("1") // returns "urn:logto:organization:1"
    /// ```
    public static func buildOrganizationUrn(forId id: String) -> String {
        organizationUrnPrefix + id
    }

    public static func isOrganizationUrn(_ value: String?) -> Bool {
        value?.hasPrefix(organizationUrnPrefix) ?? false
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
