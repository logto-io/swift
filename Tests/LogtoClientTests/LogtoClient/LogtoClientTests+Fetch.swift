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
        } catch let error as LogtoClient.Errors.OidcConfig {
            XCTAssertEqual(error.type, .unableToFetchOidcConfig)
            return
        }

        XCTFail()
    }

    func testFetchUserInfoUnalbeToGetAccessToken() async throws {
        let client = buildClient(withOidcEndpoint: "/oidc_config:bad")

        do {
            _ = try await client.fetchUserInfo()
        } catch let error as LogtoClient.Errors.AccessToken {
            XCTAssertEqual(error.type, .noRefreshTokenFound)
            return
        }

        XCTFail()
    }

    func testFetchUserInfoUnableToFetchUserInfo() async throws {
        let client = buildClient(withOidcEndpoint: "/oidc_config:good")

        client.accessTokenMap[client.buildAccessTokenKey(for: nil, scopes: [])] = AccessToken(
            token: "bad",
            scope: "",
            expiresAt: Date().timeIntervalSince1970 + 1000
        )

        do {
            _ = try await client.fetchUserInfo()
        } catch let error as LogtoClient.Errors.UserInfo {
            XCTAssertEqual(error.type, .unableToFetchUserInfo)
            return
        }

        XCTFail()
    }

    func testFetchUserInfoOk() async throws {
        let client = buildClient(withOidcEndpoint: "/oidc_config:good")

        client
            .accessTokenMap[client.buildAccessTokenKey(for: nil, scopes: [])] = AccessToken(
                token: "good",
                scope: "",
                expiresAt: Date().timeIntervalSince1970 + 1000
            )

        let info = try await client.fetchUserInfo()
        XCTAssertNotNil(info)
    }
}
