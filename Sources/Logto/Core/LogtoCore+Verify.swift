//
//  LogtoCore+Verify.swift
//
//
//  Created by Gao Sun on 2022/1/19.
//

import Foundation

extension LogtoCore {
    static func verifyAndParseSignInCallbackUri(
        _ callbackUri: String,
        redirectUri: String,
        state: String
    ) throws -> String {
        guard callbackUri.starts(with: redirectUri) else {
            throw LogtoErrors.UriVerification.redirectUriMismatched
        }

        guard let components = URLComponents(string: callbackUri) else {
            throw LogtoErrors.UriVerification.decodeComponentsFailed
        }

        guard components.queryItems?.contains(where: { $0.name == "state" && $0.value == state }) ?? false else {
            throw LogtoErrors.UriVerification.stateMismatched
        }

        let errorItems = components.queryItems?.filter { ["error", "error_description"].contains($0.name) } ?? []

        guard errorItems.count == 0 else {
            throw LogtoErrors.UriVerification.errorItemFound(items: errorItems)
        }

        guard let code = components.queryItems?.first(where: { $0.name == "code" })?.value else {
            throw LogtoErrors.UriVerification.missingCode
        }

        return code
    }
}
