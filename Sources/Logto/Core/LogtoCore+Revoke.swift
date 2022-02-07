//
//  LogtoCore+Revoke.swift
//
//
//  Created by Gao Sun on 2022/1/20.
//

import Foundation

public extension LogtoCore {
    static func revoke(
        useSession session: NetworkSession = URLSession.shared,
        token: String,
        revocationEndpoint: String,
        clientId: String,
        completion: @escaping HttpEmptyCompletion
    ) {
        let body: [String: String?] = [
            "token": token,
            "client_id": clientId,
        ]

        LogtoRequest.post(
            useSession: session,
            endpoint: revocationEndpoint,
            headers: postHeaders,
            body: body.urlParamEncoded.data(using: .utf8),
            completion: completion
        )
    }
}
