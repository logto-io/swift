import Logto
@testable import LogtoClient
import XCTest

extension LogtoClientTests {
    func testFetchOidcConfigOk() throws {
        let client = buildClient()
        let expectOk = expectation(description: "Fetch OpenID config OK")

        XCTAssertNil(client.oidcConfig)

        client.fetchOidcConfig {
            XCTAssertNotNil($0)
            XCTAssertNil($1)
            XCTAssertNotNil(client.oidcConfig)
            expectOk.fulfill()
        }

        wait(for: [expectOk], timeout: 1)
    }

    func testFetchOidcConfigCachedOk() throws {
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
        let expectOk = expectation(description: "Fetch OpenID config OK")

        client.oidcConfig = mockConfig
        client.fetchOidcConfig { oidcConfig, _ in
            XCTAssertEqual(oidcConfig, mockConfig)
            XCTAssertEqual(client.oidcConfig, mockConfig)
            expectOk.fulfill()
        }

        wait(for: [expectOk], timeout: 1)
    }

    func testFetchOidcConfigFailed() throws {
        let client = buildClient(withOidcEndpoint: "/bad")
        let expectFailure = expectation(description: "Fetch OpenID config failed")

        XCTAssertNil(client.oidcConfig)

        client.fetchOidcConfig {
            XCTAssertNil($0)
            XCTAssertNotNil($1)
            XCTAssertNil(client.oidcConfig)
            expectFailure.fulfill()
        }

        wait(for: [expectFailure], timeout: 1)
    }

    func testFetchUserInfoUnalbeToFetchOidcConfig() throws {
        let client = buildClient(withOidcEndpoint: "/bad")
        let expectFailure = expectation(description: "Fetch user info failed")

        client.fetchUserInfo {
            XCTAssertNil($0)
            XCTAssertEqual($1?.type, .unableToFetchOidcConfig)
            expectFailure.fulfill()
        }

        wait(for: [expectFailure], timeout: 1)
    }

    func testFetchUserInfoUnalbeToGetAccessToken() throws {
        let client = buildClient(withOidcEndpoint: "/oidc_config:bad")
        let expectFailure = expectation(description: "Fetch user info failed")

        client.fetchUserInfo {
            XCTAssertNil($0)
            XCTAssertEqual($1?.type, .unableToGetAccessToken)
            expectFailure.fulfill()
        }

        wait(for: [expectFailure], timeout: 1)
    }

    func testFetchUserInfoUnableToFetchUserInfo() throws {
        let client = buildClient(withOidcEndpoint: "/oidc_config:good")
        let expectFailure = expectation(description: "Fetch user info failed")

        client
            .accessTokenMap[client.buildAccessTokenKey(for: nil, scopes: [])] = AccessToken(token: "bad", scope: "",
                                                                                            expiresAt: Date()
                                                                                                .timeIntervalSince1970 +
                                                                                                1000)

        client.fetchUserInfo {
            XCTAssertNil($0)
            XCTAssertEqual($1?.type, .unableToFetchUserInfo)
            expectFailure.fulfill()
        }

        wait(for: [expectFailure], timeout: 1)
    }

    func testFetchUserInfoOk() throws {
        let client = buildClient(withOidcEndpoint: "/oidc_config:good")
        let expectOk = expectation(description: "Fetch user info OK")

        client
            .accessTokenMap[client.buildAccessTokenKey(for: nil, scopes: [])] = AccessToken(token: "good", scope: "",
                                                                                            expiresAt: Date()
                                                                                                .timeIntervalSince1970 +
                                                                                                1000)

        client.fetchUserInfo {
            XCTAssertNotNil($0)
            XCTAssertNil($1)
            expectOk.fulfill()
        }

        wait(for: [expectOk], timeout: 1)
    }
}
