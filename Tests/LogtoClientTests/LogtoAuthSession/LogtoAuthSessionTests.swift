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

    func testHandleUnableToFetchToken() async throws {
        let session = LogtoAuthSession(
            useSession: NetworkSessionMock.shared,
            logtoConfig: try! LogtoConfig(endpoint: "https://logto.dev", clientId: ""),
            oidcConfig: getMockOidcConfig(authorizationEndpoint: "https://logto.dev/auth"),
            redirectUri: redirectUri,
            socialPlugins: []
        )

        var components = URLComponents(url: redirectUri, resolvingAgainstBaseURL: true)!
        components.queryItems = [
            URLQueryItem(name: "state", value: session.state),
            URLQueryItem(name: "code", value: "abc"),
        ]

        do {
            _ = try await session.handle(callbackUri: components.url!)
        } catch let error as LogtoClient.Errors.SignIn {
            XCTAssertEqual(error.type, .unableToFetchToken)
            return
        }

        XCTFail()
    }

    func testHandleOk() async throws {
        let session = LogtoAuthSession(
            useSession: NetworkSessionMock.shared,
            logtoConfig: try! LogtoConfig(endpoint: "https://logto.dev", clientId: ""),
            oidcConfig: getMockOidcConfig(
                authorizationEndpoint: "https://logto.dev/auth",
                tokenEndpoint: "https://logto.dev/token:good"
            ),
            redirectUri: redirectUri,
            socialPlugins: []
        )

        var components = URLComponents(url: redirectUri, resolvingAgainstBaseURL: true)!
        components.queryItems = [
            URLQueryItem(name: "state", value: session.state),
            URLQueryItem(name: "code", value: "abc"),
        ]

        _ = try await session.handle(callbackUri: components.url!)
    }
}
