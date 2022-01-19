//
//  URLSessionMock.swift
//  https://www.swiftbysundell.com/articles/mocking-in-swift/
//
//  Created by Gao Sun on 2022/1/19.
//

import Foundation
@testable import Logto

class MockError: LocalizedError {}

class NetworkSessionMock: NetworkSession {
    static let shared = NetworkSessionMock()

    func loadData(
        with url: URL,
        completion: @escaping HttpCompletion<Data>
    ) {
        switch url.path {
        case "/oidc_config:good":
            completion(Data("""
                {
                    "authorization_endpoint": "https://logto.dev/oidc/auth",
                    "token_endpoint": "https://logto.dev/oidc/token",
                    "end_session_endpoint": "https://logto.dev/oidc/session/end",
                    "revocation_endpoint": "https://logto.dev/oidc/token/revocation",
                    "jwks_uri": "https://logto.dev/oidc/jwks",
                    "issuer": "http://localhost:443/oidc"
                }
            """.utf8), nil)
        default:
            completion(nil, MockError())
        }
    }

    func loadData(
        with request: URLRequest,
        completion: @escaping HttpCompletion<Data>
    ) {
        guard let method = request.httpMethod, method.lowercased() != "get" else {
            completion(nil, MockError())
            return
        }

        switch request.url?.path {
        case "/token:good":
            completion(Data("""
                {
                    "access_token": "123",
                    "refresh_token": "456",
                    "id_token": "789",
                    "token_type": "jwt",
                    "scope": "",
                    "expires_in": 123
                }
            """.utf8), nil)
        default:
            completion(nil, MockError())
        }
    }
}
