import Logto
@testable import LogtoClient
import LogtoMock
import XCTest

class LogtoAuthSessionSuccessMock: LogtoAuthSession {
    override func start() {
        completion(.success(response: try! JSONDecoder().decode(LogtoCore.CodeTokenResponse.self, from: Data("""
        {
            "accessToken": "foo",
            "refreshToken": "bar",
            "idToken": "baz",
            "scope": "openid offline_access",
            "expiresIn": 300
        }
        """.utf8))))
    }
}

class LogtoAuthSessionFailureMock: LogtoAuthSession {
    override func start() {
        completion(.failure(error: LogtoAuthSession.Errors.SignIn(type: .unknownError, innerError: nil)))
    }
}

extension LogtoClientTests {
    func testSignInOk() throws {
        let client = buildClient()
        let expectOk = expectation(description: "Sign in OK")

        client.signInWithBrowser(
            authSessionType: LogtoAuthSessionSuccessMock.self,
            redirectUri: "io.logto.dev://callback"
        ) {
            XCTAssertNil($0)
            XCTAssertEqual(client.idToken, "baz")
            XCTAssertEqual(client.refreshToken, "bar")
            XCTAssertEqual(client.accessTokenMap[client.buildAccessTokenKey(for: nil, scopes: [])]?.token, "foo")
            expectOk.fulfill()
        }

        wait(for: [expectOk], timeout: 1)
    }

    func testSignInUnableToConstructRedirectUri() throws {
        let client = buildClient()
        let expectFailure = expectation(description: "Sign in failure")

        client.signInWithBrowser(redirectUri: "") {
            XCTAssertEqual($0?.type, .unableToConstructRedirectUri)
            expectFailure.fulfill()
        }

        wait(for: [expectFailure], timeout: 1)
    }

    func testSignInUnableToFetchOidcConfig() throws {
        let client = buildClient(withOidcEndpoint: "/bad")
        let expectFailure = expectation(description: "Sign in failure")

        client.signInWithBrowser(redirectUri: "io.logto.dev://callback") {
            XCTAssertEqual($0?.type, .unableToFetchOidcConfig)
            expectFailure.fulfill()
        }

        wait(for: [expectFailure], timeout: 1)
    }

    func testSignInUnknownError() throws {
        let client = buildClient()
        let expectFailure = expectation(description: "Sign in OK")

        client.signInWithBrowser(
            authSessionType: LogtoAuthSessionFailureMock.self,
            redirectUri: "io.logto.dev://callback"
        ) {
            XCTAssertEqual($0?.type, .unknownError)
            expectFailure.fulfill()
        }

        wait(for: [expectFailure], timeout: 1)
    }
}
