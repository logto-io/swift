import Logto
@testable import LogtoClient
import LogtoMock
import XCTest

class LogtoAuthSessionSuccessMock: LogtoAuthSession {
    override func start() async throws -> LogtoCore.CodeTokenResponse {
        try! JSONDecoder().decode(LogtoCore.CodeTokenResponse.self, from: Data("""
            {
                "accessToken": "foo",
                "refreshToken": "bar",
                "idToken": "baz",
                "scope": "openid offline_access",
                "expiresIn": 300
            }
        """.utf8))
    }
}

class LogtoAuthSessionFailureMock: LogtoAuthSession {
    override func start() async throws -> LogtoCore.CodeTokenResponse {
        throw LogtoAuthSession.Errors.SignIn(type: .unknownError, innerError: nil)
    }
}

class LogtoAuthSessionCaptureMock: LogtoAuthSession {
    static var capturedLoginHint: String?
    static var capturedDirectSignIn: LogtoCore.DirectSignInOptions?
    static var capturedExtraParams: [String: String]?

    static func reset() {
        capturedLoginHint = nil
        capturedDirectSignIn = nil
        capturedExtraParams = nil
    }

    required init(
        useSession session: NetworkSession = URLSession.shared,
        logtoConfig: LogtoConfig,
        oidcConfig: LogtoCore.OidcConfigResponse,
        redirectUri: URL,
        socialPlugins: [LogtoSocialPlugin],
        loginHint: String? = nil,
        directSignIn: LogtoCore.DirectSignInOptions? = nil,
        extraParams: [String: String]? = nil
    ) {
        super.init(
            useSession: session,
            logtoConfig: logtoConfig,
            oidcConfig: oidcConfig,
            redirectUri: redirectUri,
            socialPlugins: socialPlugins,
            loginHint: loginHint,
            directSignIn: directSignIn,
            extraParams: extraParams
        )

        Self.capturedLoginHint = loginHint
        Self.capturedDirectSignIn = directSignIn
        Self.capturedExtraParams = extraParams
    }

    override func start() async throws -> LogtoCore.CodeTokenResponse {
        throw LogtoAuthSession.Errors.SignIn(type: .unknownError, innerError: nil)
    }
}

extension LogtoClientTests {
    func testSignInUnableToFetchJwkSet() async throws {
        let client = buildClient(withToken: true)

        do {
            try await client.signInWithBrowser(
                authSessionType: LogtoAuthSessionSuccessMock.self,
                redirectUri: "io.logto.dev://callback"
            )
        } catch let error as LogtoClientErrors.JwkSet {
            XCTAssertEqual(error.type, .unableToFetchJwkSet)
            XCTAssertEqual(client.idToken, initialIdToken)
            return
        }

        XCTFail()
    }

    func testSignInUnableToConstructRedirectUri() async throws {
        let client = buildClient()

        do {
            try await client.signInWithBrowser(redirectUri: "")
        } catch let error as LogtoClientErrors.SignIn {
            XCTAssertEqual(error.type, .unableToConstructRedirectUri)
            return
        }

        XCTFail()
    }

    func testSignInUnableToFetchOidcConfig() async throws {
        let client = buildClient(withOidcEndpoint: "/bad")

        do {
            _ = try await client.signInWithBrowser(redirectUri: "io.logto.dev://callback")
        } catch let error as LogtoClientErrors.OidcConfig {
            XCTAssertEqual(error.type, .unableToFetchOidcConfig)
            return
        }

        XCTFail()
    }

    func testSignInPassesOptionalParametersToAuthSession() async throws {
        LogtoAuthSessionCaptureMock.reset()

        let client = buildClient()
        let directSignIn = LogtoCore.DirectSignInOptions(method: .social, target: "google")
        let extraParams = ["organization_id": "org_123"]

        do {
            try await client.signInWithBrowser(
                authSessionType: LogtoAuthSessionCaptureMock.self,
                redirectUri: "io.logto.dev://callback",
                loginHint: "foo@logto.dev",
                directSignIn: directSignIn,
                extraParams: extraParams
            )
        } catch let error as LogtoClientErrors.SignIn {
            XCTAssertEqual(error.type, .unknownError)
            XCTAssertEqual(LogtoAuthSessionCaptureMock.capturedLoginHint, "foo@logto.dev")
            XCTAssertNotNil(LogtoAuthSessionCaptureMock.capturedDirectSignIn)
            XCTAssertEqual(LogtoAuthSessionCaptureMock.capturedExtraParams, extraParams)
            return
        }

        XCTFail()
    }

    func testSignInUnknownError() async throws {
        let client = buildClient()

        do {
            try await client.signInWithBrowser(
                authSessionType: LogtoAuthSessionFailureMock.self,
                redirectUri: "io.logto.dev://callback"
            )
        } catch let error as LogtoClientErrors.SignIn {
            XCTAssertEqual(error.type, .unknownError)
            return
        }

        XCTFail()
    }
}
