//
//  LogtoCore+Revoke.swift
//
//
//  Created by Gao Sun on 2022/1/20.
//

import Foundation

extension LogtoCore {
    static func revoke(
        useSession session: NetworkSession = URLSession.shared,
        token: String,
        revocationEndpoint: String,
        clientId: String,
        completion: @escaping HttpEmptyCompletion
    ) {
        let body: [String: Any] = [
            "token": token,
            "client_id": clientId,
        ]

        do {
            let data = try JSONSerialization.data(withJSONObject: body)
            LogtoRequest.post(useSession: session, endpoint: revocationEndpoint, body: data, completion: completion)
        } catch {
            completion(error)
        }
    }
}
