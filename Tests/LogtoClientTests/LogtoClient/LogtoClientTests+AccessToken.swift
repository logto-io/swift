import Logto
@testable import LogtoClient
import LogtoMock
import XCTest

extension LogtoClientTests {
    func testGetAccessTokenCached() async throws {
        let client = buildClient()
        let cachedAccessToken = "foo"

        client.accessTokenMap[client.buildAccessTokenKey(for: nil, in: nil)] = AccessToken(
            token: cachedAccessToken,
            scope: "",
            expiresAt: Date().timeIntervalSince1970 + 1000
        )

        let token = try await client.getAccessToken(for: nil)
        XCTAssertEqual(token, cachedAccessToken)
    }

    func testGetOrganizationwTokenCached() async throws {
        let client = buildClient()
        let cachedAccessToken = "foo"

        client
            .accessTokenMap[client.buildAccessTokenKey(for: LogtoUtilities.buildOrganizationUrn(forId: "1"), in: nil)] =
            AccessToken(
                token: cachedAccessToken,
                scope: "",
                expiresAt: Date().timeIntervalSince1970 + 1000
            )

        let token = try await client.getOrganizationToken(forId: "1")
        XCTAssertEqual(token, cachedAccessToken)
    }

    func testGetAccessTokenByRefreshToken() async throws {
        NetworkSessionMock.shared.tokenRequestCount = 0

        let client = buildClient()
        client.refreshToken = "bar"
        client.accessTokenMap[client.buildAccessTokenKey(for: "resource1", in: nil)] = AccessToken(
            token: "foo",
            scope: "",
            expiresAt: Date().timeIntervalSince1970 - 1000
        )

        let token1 = try await client.getAccessToken(for: "resource1")
        try await Task.sleep(nanoseconds: 1_050_000_000) // 1.05s to make token expired
        let token2 = try await client.getAccessToken(for: "resource1")

        XCTAssertEqual(token1, "123")
        XCTAssertEqual(token2, "456")
        XCTAssertEqual(client.refreshToken, "789")
        XCTAssertEqual(client.idToken, "abc")
    }

    func testGetAccessTokenByRefreshTokenWithoutRefreshAndIdTokenReturned() async throws {
        NetworkSessionMock.shared.tokenRequestCount = 0

        let client = buildClient(withOidcEndpoint: "/oidc_config:good:no_refresh")
        client.idToken = "baz"
        client.refreshToken = "bar"
        client.accessTokenMap[client.buildAccessTokenKey(for: "resource1", in: nil)] = AccessToken(
            token: "foo",
            scope: "",
            expiresAt: Date().timeIntervalSince1970 - 1000
        )

        let token = try await client.getAccessToken(for: "resource1")

        XCTAssertEqual(token, "123")
        XCTAssertEqual(client.refreshToken, "bar")
        XCTAssertEqual(client.idToken, "baz")
    }

    func testGetAccessTokenUnalbeToFetchOidcConfig() async throws {
        let client = buildClient(withOidcEndpoint: "/bad")

        client.refreshToken = "foo"

        do {
            _ = try await client.getAccessToken(for: nil)
        } catch let error as LogtoClientErrors.OidcConfig {
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
        } catch let error as LogtoClientErrors.AccessToken {
            XCTAssertEqual(error.type, .unableToFetchTokenByRefreshToken)
            return
        }

        XCTFail()
    }

    func testGetOrganizationToken() async throws {
        let client = buildClient(withOidcEndpoint: "/oidc_config:good:jwt")
        client.refreshToken = "foo"

        let token = try await client.getOrganizationToken(forId: "1")
        XCTAssertEqual(token, NetworkSessionMock.goodAccessTokenJWT)
    }

    func testGetAccessTokenClaims() async throws {
        let client = buildClient(withOidcEndpoint: "/oidc_config:good:jwt")
        client.refreshToken = "foo"

        let token = try await client.getAccessTokenClaims(for: "any_resource", organizationId: "any_org")
        XCTAssertEqual(token["sub"]?.stringValue, "1234567890")
        XCTAssertEqual(token["iss"]?.stringValue, "https://logto.dev")
        XCTAssertEqual(token["customClaims"]?.objectValue?["role"]?.stringValue, "admin")
        XCTAssertEqual(token["customClaims"]?.objectValue?["age"]?.numberValue, 30)
    }
}
