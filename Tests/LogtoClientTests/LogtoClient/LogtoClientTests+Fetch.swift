import Logto
@testable import LogtoClient
import XCTest

extension LogtoClientTests {
    func testFetchOidcConfigOk() async throws {
        let client = buildClient()

        XCTAssertNil(client.oidcConfig)

        let config = try await client.fetchOidcConfig()
        XCTAssertNotNil(config)
        XCTAssertEqual(config, client.oidcConfig)
    }

    func testFetchOidcConfigCachedOk() async throws {
        let client = buildClient()
        let mockConfig = try! JSONDecoder().decode(LogtoCore.OidcConfigResponse.self, from: Data("""
            {
                "authorizationEndpoint": "1",
                "tokenEndpoint": "2",
                "endSessionEndpoint": "3",
                "revocationEndpoint": "4",
                "userinfoEndpoint": "5",
                "jwksUri": "6",
                "issuer": "7"
            }
        """.utf8))

        client.oidcConfig = mockConfig
        let config = try await client.fetchOidcConfig()
        XCTAssertEqual(config, mockConfig)
        XCTAssertEqual(client.oidcConfig, mockConfig)
    }

    func testFetchOidcConfigFailed() async throws {
        let client = buildClient(withOidcEndpoint: "/bad")
        XCTAssertNil(client.oidcConfig)

        do {
            _ = try await client.fetchOidcConfig()
        } catch {
            XCTAssertNil(client.oidcConfig)
            return
        }

        XCTFail()
    }

    func testFetchUserInfoUnalbeToFetchOidcConfig() async throws {
        let client = buildClient(withOidcEndpoint: "/bad")

        do {
            _ = try await client.fetchUserInfo()
        } catch let error as LogtoClientErrors.OidcConfig {
            XCTAssertEqual(error.type, .unableToFetchOidcConfig)
            return
        }

        XCTFail()
    }

    func testFetchUserInfoUnalbeToGetAccessToken() async throws {
        let client = buildClient(withOidcEndpoint: "/oidc_config:bad")

        do {
            _ = try await client.fetchUserInfo()
        } catch let error as LogtoClientErrors.AccessToken {
            XCTAssertEqual(error.type, .noRefreshTokenFound)
            return
        }

        XCTFail()
    }

    func testFetchUserInfoUnableToFetchUserInfo() async throws {
        let client = buildClient(withOidcEndpoint: "/oidc_config:good")

        client.accessTokenMap[client.buildAccessTokenKey(for: nil, in: nil)] = AccessToken(
            token: "bad",
            scope: "",
            expiresAt: Date().timeIntervalSince1970 + 1000
        )

        do {
            _ = try await client.fetchUserInfo()
        } catch let error as LogtoClientErrors.UserInfo {
            XCTAssertEqual(error.type, .unableToFetchUserInfo)
            return
        }

        XCTFail()
    }

    func testFetchUserInfoOk() async throws {
        let client = buildClient(withOidcEndpoint: "/oidc_config:good")

        client
            .accessTokenMap[client.buildAccessTokenKey(for: nil, in: nil)] = AccessToken(
                token: "good",
                scope: "",
                expiresAt: Date().timeIntervalSince1970 + 1000
            )

        let info = try await client.fetchUserInfo()
        XCTAssertNotNil(info)
    }

    func testBuildFetchTokenPayloadByRefreshToken() {
        let payload1 = LogtoCore.buildFetchTokenPayload(
            byRefreshToken: "refreshToken",
            clientId: "clientId",
            resource: "resource",
            scopes: ["scope1", "scope2"],
            organizationId: "orgId"
        )
        XCTAssertEqual(payload1["grant_type"] as? String, "refresh_token")
        XCTAssertEqual(payload1["refresh_token"] as? String, "refreshToken")
        XCTAssertEqual(payload1["client_id"] as? String, "clientId")
        XCTAssertEqual(payload1["resource"] as? String, "resource")
        XCTAssertEqual(payload1["organization_id"] as? String, "orgId")
        XCTAssertEqual(payload1["scope"] as? String, "scope1 scope2")

        let payload2 = LogtoCore.buildFetchTokenPayload(
            byRefreshToken: "refreshToken",
            clientId: "clientId",
            resource: LogtoUtilities.buildOrganizationUrn(forId: "orgId"),
            scopes: nil,
            organizationId: nil
        )
        XCTAssertEqual(payload2["grant_type"] as? String, "refresh_token")
        XCTAssertEqual(payload2["refresh_token"] as? String, "refreshToken")
        XCTAssertEqual(payload2["client_id"] as? String, "clientId")
        XCTAssertNil(payload2["resource"] as? String)
        XCTAssertEqual(payload2["organization_id"] as? String, "orgId")
        XCTAssertNil(payload2["scope"] as? String)

        let payload3 = LogtoCore.buildFetchTokenPayload(
            byRefreshToken: "refreshToken",
            clientId: "clientId",
            resource: LogtoUtilities.buildOrganizationUrn(forId: "orgId"),
            scopes: nil,
            organizationId: "anotherOrgId"
        )
        XCTAssertEqual(payload3["grant_type"] as? String, "refresh_token")
        XCTAssertEqual(payload3["refresh_token"] as? String, "refreshToken")
        XCTAssertEqual(payload3["client_id"] as? String, "clientId")
        XCTAssertNil(payload3["resource"] as? String)
        XCTAssertEqual(payload3["organization_id"] as? String, "orgId")
        XCTAssertNil(payload3["scope"] as? String)
    }
}
