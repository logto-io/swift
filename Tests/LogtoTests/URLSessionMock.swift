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
        from url: URL,
        completion: @escaping (Data?, Error?) -> Void
    ) {
        switch url.absoluteString {
        case "OidcConfig:good":
            completion(Data("""
                {
                    "authorizationEndpoint": "https://logto.dev/oidc/auth",
                    "tokenEndpoint": "https://logto.dev/oidc/token",
                    "endSessionEndpoint": "https://logto.dev/oidc/session/end",
                    "revocationEndpoint": "https://logto.dev/oidc/token/revocation",
                    "jwksUri": "https://logto.dev/oidc/jwks",
                    "issuer": "http://localhost:443/oidc"
                }
            """.utf8), nil)
        default:
            completion(nil, MockError())
        }
    }
}
