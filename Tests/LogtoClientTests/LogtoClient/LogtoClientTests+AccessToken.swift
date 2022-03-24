import Logto
@testable import LogtoClient
import LogtoMock
import XCTest

extension LogtoClientTests {
    func testGetAccessTokenCached() async throws {
        let client = buildClient()

        client.accessTokenMap[client.buildAccessTokenKey(for: nil, scopes: [])] = AccessToken(
            token: "foo",
            scope: "",
            expiresAt: Date().timeIntervalSince1970 + 1000
        )

        let token = try await client.getAccessToken(for: nil)
        XCTAssertEqual(token, "foo")
    }

    func testGetAccessTokenByRefreshToken() async throws {
        NetworkSessionMock.shared.tokenRequestCount = 0

        let client = buildClient()
        client.refreshToken = "bar"
        client.accessTokenMap[client.buildAccessTokenKey(for: "resource1", scopes: [])] = AccessToken(
            token: "foo",
            scope: "",
            expiresAt: Date().timeIntervalSince1970 - 1
        )

        async let get1 = client.getAccessToken(for: "resource1")
        async let get2 = client.getAccessToken(for: "resource1")
        let tokens = try await [get1, get2]

        XCTAssertEqual(tokens[0], "123")
        XCTAssertEqual(tokens[1], "123")
    }

    func testGetAccessTokenUnalbeToFetchOidcConfig() async throws {
        let client = buildClient(withOidcEndpoint: "/bad")

        client.refreshToken = "foo"

        do {
            _ = try await client.getAccessToken(for: nil)
        } catch let error as LogtoClient.Errors.OidcConfig {
            XCTAssertEqual(error.type, .unableToFetchOidcConfig)
            return
        }

        XCTFail()
    }

    func testGetAccessTokenUnalbeToFetchTokenByRefreshToken() async throws {
        let client = buildClient(withOidcEndpoint: "/oidc_config:bad")

        client.refreshToken = "foo"

        do {
            _ = try await client.getAccessToken(for: nil)
        } catch let error as LogtoClient.Errors.AccessToken {
            XCTAssertEqual(error.type, .unableToFetchTokenByRefreshToken)
            return
        }

        XCTFail()
    }
}
