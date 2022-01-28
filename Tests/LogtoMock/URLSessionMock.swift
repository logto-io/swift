//
//  URLSessionMock.swift
//  https://www.swiftbysundell.com/articles/mocking-in-swift/
//
//  Created by Gao Sun on 2022/1/19.
//

import Foundation
@testable import Logto

public class MockError: LocalizedError {}

public class NetworkSessionMock: NetworkSession {
    public static let shared = NetworkSessionMock()

    public func loadData(
        with request: URLRequest,
        completion: @escaping HttpCompletion<Data>
    ) {
        switch request.httpMethod {
        case "GET":
            switch request.url?.pathComponents[safe: 1] {
            case "oidc_config:good":
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
            case "user":
                guard request.value(forHTTPHeaderField: "Authorization") == "Bearer good" else {
                    completion(nil, MockError())
                    return
                }

                completion(Data("""
                    {
                        "sub": "foo"
                    }
                """.utf8), nil)
            default:
                completion(nil, MockError())
            }
        case "POST":
            switch request.url?.pathComponents[safe: 1] {
            case "token:good":
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
            case "revoke:good":
                completion(nil, nil)
            default:
                completion(nil, MockError())
            }
        default:
            completion(nil, MockError())
        }
    }
}
