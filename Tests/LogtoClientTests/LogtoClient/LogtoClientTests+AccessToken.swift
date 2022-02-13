import Logto
@testable import LogtoClient
import XCTest

extension LogtoClientTests {
    func testGetAccessTokenCached() throws {
        let client = buildClient()
        let expectOk = expectation(description: "Get access token OK")

        client.accessTokenMap[client.buildAccessTokenKey(for: nil, scopes: [])] = AccessToken(
            token: "foo",
            scope: "",
            expiresAt: Date().timeIntervalSince1970 + 1000
        )

        client.getAccessToken(for: nil) {
            XCTAssertEqual($0, "foo")
            XCTAssertNil($1)
            expectOk.fulfill()
        }

        wait(for: [expectOk], timeout: 1)
    }
    
    func testGetAccessTokenByRefreshToken() throws {
        let client = buildClient()
        let expectOk = expectation(description: "Get access token OK")

        client.refreshToken = "bar"
        client.accessTokenMap[client.buildAccessTokenKey(for: "resource1", scopes: [])] = AccessToken(
            token: "foo",
            scope: "",
            expiresAt: Date().timeIntervalSince1970 - 1
        )

        client.getAccessToken(for: "resource1") {
            XCTAssertEqual($0, "123")
            XCTAssertNil($1)
            expectOk.fulfill()
        }

        wait(for: [expectOk], timeout: 1)
    }
    
    func testGetAccessTokenUnalbeToFetchOidcConfig() throws {
        let client = buildClient(withOidcEndpoint: "/bad")
        let expectFailure = expectation(description: "Get access token failed")

        client.getAccessToken(for: nil) {
            XCTAssertNil($0)
            XCTAssertEqual($1?.type, .unableToFetchOidcConfig)
            expectFailure.fulfill()
        }

        wait(for: [expectFailure], timeout: 1)
    }
    
    func testGetAccessTokenUnalbeToFetchTokenByRefreshToken() throws {
        let client = buildClient(withOidcEndpoint: "/oidc_config:bad")
        let expectFailure = expectation(description: "Get access token failed")

        client.getAccessToken(for: nil) {
            XCTAssertNil($0)
            XCTAssertEqual($1?.type, .unableToFetchTokenByRefreshToken)
            expectFailure.fulfill()
        }

        wait(for: [expectFailure], timeout: 1)
    }
}
