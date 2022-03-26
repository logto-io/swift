import AuthenticationServices
import Logto
@testable import LogtoClient
import LogtoMock
import XCTest

private let redirectUri = URL(string: "io.logto.test://callback")!

final class LogtoAuthSessionTests: XCTestCase {
    func getMockOidcConfig(
        authorizationEndpoint: String = "https://logto.dev/canceled",
        tokenEndpoint: String = "https://logto.dev/token:bad"
    ) -> LogtoCore
        .OidcConfigResponse
    {
        try! JSONDecoder().decode(LogtoCore.OidcConfigResponse.self, from: Data("""
            {
                "authorizationEndpoint": "\(authorizationEndpoint)",
                "tokenEndpoint": "\(tokenEndpoint)",
                "endSessionEndpoint": "",
                "revocationEndpoint": "",
                "userinfoEndpoint": "",
                "jwksUri": "",
                "issuer": ""
            }
        """.utf8))
    }

    func testHandleUnableToFetchToken() async {
        let expectFailure = expectation(description: "Auth handle failure")
        let session = LogtoAuthSession(
            useSession: NetworkSessionMock.shared,
            logtoConfig: try! LogtoConfig(endpoint: "https://logto.dev", clientId: ""),
            oidcConfig: getMockOidcConfig(authorizationEndpoint: "https://logto.dev/auth"),
            redirectUri: redirectUri
        ) {
            guard case let .failure(error: error) = $0, error.type == .unableToFetchToken
            else {
                XCTFail()
                return
            }

            expectFailure.fulfill()
        }

        var components = URLComponents(url: redirectUri, resolvingAgainstBaseURL: true)!
        components.queryItems = [
            URLQueryItem(name: "state", value: session.state),
            URLQueryItem(name: "code", value: "abc"),
        ]

        await session.handle(callbackUri: components.url!)
        wait(for: [expectFailure], timeout: 1)
    }

    func testHandleOk() async {
        let expectOk = expectation(description: "Auth handle OK")
        let session = LogtoAuthSession(
            useSession: NetworkSessionMock.shared,
            logtoConfig: try! LogtoConfig(endpoint: "https://logto.dev", clientId: ""),
            oidcConfig: getMockOidcConfig(
                authorizationEndpoint: "https://logto.dev/auth",
                tokenEndpoint: "https://logto.dev/token:good"
            ),
            redirectUri: redirectUri
        ) {
            guard case .success(response: _) = $0
            else {
                XCTFail()
                return
            }

            expectOk.fulfill()
        }

        var components = URLComponents(url: redirectUri, resolvingAgainstBaseURL: true)!
        components.queryItems = [
            URLQueryItem(name: "state", value: session.state),
            URLQueryItem(name: "code", value: "abc"),
        ]

        await session.handle(callbackUri: components.url!)
        wait(for: [expectOk], timeout: 1)
    }
}
