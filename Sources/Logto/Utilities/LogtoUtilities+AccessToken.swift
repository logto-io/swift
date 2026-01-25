//
//  LogtoUtilities+AccessToken.swift
//  LogtoSDK
//
//  Created by Gao Sun on 1/24/26.
//

import Foundation
import JOSESwift

public extension LogtoUtilities {
    /// Decode Access Token claims WITHOUT validation.
    /// - Parameter token: The JWT to decode.
    /// - Returns: A dictionary of Access Token claims.
    static func decodeAccessToken(_ accessToken: String) throws -> JsonObject {
        let decoder = LogtoUtilities.getCamelCaseDecoder()
        let segments = accessToken.split(separator: ".")

        guard let payload = segments[safe: 1] else {
            throw LogtoErrors.Decoding.noPayloadFound
        }

        guard let decoded = String.fromUrlSafeBase64(string: String(payload)) else {
            throw LogtoErrors.Decoding.invalidUrlSafeBase64Encoding
        }

        return try decoder.decode(JsonObject.self, from: Data(decoded.utf8))
    }
}
