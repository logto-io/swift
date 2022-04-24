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

    func createGoodSession() -> LogtoAuthSession {
        LogtoAuthSession(
            useSession: NetworkSessionMock.shared,
            logtoConfig: try! LogtoConfig(endpoint: "https://logto.dev", appId: ""),
            oidcConfig: getMockOidcConfig(
                authorizationEndpoint: "https://logto.dev/auth",
                tokenEndpoint: "https://logto.dev/token:good"
            ),
            redirectUri: redirectUri,
            socialPlugins: []
        )
    }

    // Swift cannot directly mock a class or an object unless subclassing or using generic,
    // which increases unnecessary complecity for now.
    // So the test case is reduced for minimum verification.
    func testStartOk() async throws {
        let session = createGoodSession()
        let task = Task {
            _ = try await session.start()
        }

        // Explicitly sleep 0.1s to ensure there's no error when the function starts
        try await Task.sleep(nanoseconds: UInt64(0.1 * Double(NSEC_PER_SEC)))
        task.cancel()
    }

    func testStartFailed() async throws {
        let session = LogtoAuthSession(
            useSession: NetworkSessionMock.shared,
            logtoConfig: try! LogtoConfig(endpoint: "https://logto.dev", appId: ""),
            oidcConfig: getMockOidcConfig(authorizationEndpoint: "foo"),
            redirectUri: URL(string: "foo")!,
            socialPlugins: []
        )

        do {
            _ = try await session.start()
        } catch let error as LogtoClientErrors.SignIn {
            XCTAssertEqual(error.type, .unableToConstructAuthUri)
            return
        }

        XCTFail()
    }

    func testHandleUnableToFetchToken() async throws {
        let session = LogtoAuthSession(
            useSession: NetworkSessionMock.shared,
            logtoConfig: try! LogtoConfig(endpoint: "https://logto.dev", appId: ""),
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
        } catch let error as LogtoClientErrors.SignIn {
            XCTAssertEqual(error.type, .unableToFetchToken)
            return
        }

        XCTFail()
    }

    func testHandleUnexpectedSignInCallback() async throws {
        let session = createGoodSession()

        do {
            _ = try await session.handle(callbackUri: URL(string: "https://foo")!)
        } catch let error as LogtoClientErrors.SignIn {
            XCTAssertEqual(error.type, .unexpectedSignInCallback)
            return
        }

        XCTFail()
    }

    func testHandleOk() async throws {
        let session = createGoodSession()

        var components = URLComponents(url: redirectUri, resolvingAgainstBaseURL: true)!
        components.queryItems = [
            URLQueryItem(name: "state", value: session.state),
            URLQueryItem(name: "code", value: "abc"),
        ]

        _ = try await session.handle(callbackUri: components.url!)
    }
}
