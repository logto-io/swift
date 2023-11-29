//
//  NetworkSessionMock.swift
//  https://www.swiftbysundell.com/articles/mocking-in-swift/
//
//  Created by Gao Sun on 2022/1/19.
//

import Foundation
@testable import Logto

public class MockError: LocalizedError {}

public class NetworkSessionMock: NetworkSession {
    public static let shared = NetworkSessionMock()

    public var tokenRequestCount = 0

    public func loadData(
        with request: URLRequest
    ) async -> (Data?, Error?) {
        switch request.httpMethod {
        case "GET":
            switch request.url?.pathComponents[safe: 1] {
            case "oidc_config:good":
                return (Data("""
                    {
                        "authorization_endpoint": "https://logto.dev/auth:good",
                        "token_endpoint": "https://logto.dev/token:good",
                        "end_session_endpoint": "https://logto.dev/end:good",
                        "revocation_endpoint": "https://logto.dev/revoke:good",
                        "userinfo_endpoint": "https://logto.dev/user",
                        "jwks_uri": "https://logto.dev/jwks:good",
                        "issuer": "http://localhost:443/oidc"
                    }
                """.utf8), nil)
            case "oidc_config:good:no_refresh":
                return (Data("""
                    {
                        "authorization_endpoint": "https://logto.dev/auth:good",
                        "token_endpoint": "https://logto.dev/token:good:no_refresh",
                        "end_session_endpoint": "https://logto.dev/end:good",
                        "revocation_endpoint": "https://logto.dev/revoke:good",
                        "userinfo_endpoint": "https://logto.dev/user",
                        "jwks_uri": "https://logto.dev/jwks:good",
                        "issuer": "http://localhost:443/oidc"
                    }
                """.utf8), nil)
            case "oidc_config:bad":
                return (Data("""
                   {
                       "authorization_endpoint": "https://logto.dev/auth:bad",
                       "token_endpoint": "https://logto.dev/token:bad",
                       "end_session_endpoint": "https://logto.dev/end:bad",
                       "revocation_endpoint": "https://logto.dev/revoke:bad",
                       "userinfo_endpoint": "https://logto.dev/user",
                       "jwks_uri": "https://logto.dev/jwks:bad",
                       "issuer": "http://localhost:443/oidc"
                   }
                """.utf8), nil)
            case "user":
                guard request.value(forHTTPHeaderField: "Authorization") == "Bearer good" else {
                    return (nil, MockError())
                }

                return (Data("""
                    {
                        "sub": "foo"
                    }
                """.utf8), nil)
            default:
                return (nil, MockError())
            }
        case "POST":
            switch request.url?.pathComponents[safe: 1] {
            case "token:good":
                tokenRequestCount += 1

                guard tokenRequestCount <= 1 else {
                    return (Data("""
                        {
                            "access_token": "456",
                            "refresh_token": "789",
                            "id_token": "abc",
                            "token_type": "jwt",
                            "scope": "",
                            "expires_in": 123
                        }
                    """.utf8), nil)
                }

                return (Data("""
                    {
                        "access_token": "123",
                        "refresh_token": "456",
                        "id_token": "789",
                        "token_type": "jwt",
                        "scope": "",
                        "expires_in": 123
                    }
                """.utf8), nil)
            case "token:good:no_refresh":
                return (Data("""
                    {
                        "access_token": "123",
                        "token_type": "jwt",
                        "scope": "",
                        "expires_in": 123
                    }
                """.utf8), nil)
            case "revoke:good":
                return (nil, nil)
            default:
                return (nil, MockError())
            }
        default:
            return (nil, MockError())
        }
    }
}
