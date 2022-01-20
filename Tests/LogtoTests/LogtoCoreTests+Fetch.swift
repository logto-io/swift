@testable import Logto
import XCTest

extension LogtoCoreTests {
    func testFetchOidcConfig() throws {
        let expectOk = expectation(description: "Fetch OpenID config OK")
        let expectFailed = expectation(description: "Fetch OpenID config failed")

        LogtoCore.fetchOidcConfig(useSession: NetworkSessionMock.shared, endpoint: "/oidc_config:good") {
            XCTAssertNotNil($0)
            XCTAssertNil($1)
            expectOk.fulfill()
        }

        LogtoCore.fetchOidcConfig(useSession: NetworkSessionMock.shared, endpoint: "/oidc_config:bad") {
            XCTAssertNil($0)
            XCTAssertNotNil($1)
            expectFailed.fulfill()
        }

        wait(for: [expectOk, expectFailed], timeout: 1)
    }

    func testFetchToken() throws {
        let expectOk = expectation(description: "Fetch token by code OK")
        let expectFailed = expectation(description: "Fetch token by code failed")

        LogtoCore.fetchToken(
            useSession: NetworkSessionMock.shared,
            byAuthorizationCode: "123",
            codeVerifier: "456",
            tokenEndpoint: "/token:good",
            clientId: "foo",
            redirectUri: "bar"
        ) {
            XCTAssertNotNil($0)
            XCTAssertNil($1)
            expectOk.fulfill()
        }

        LogtoCore.fetchToken(
            useSession: NetworkSessionMock.shared,
            byAuthorizationCode: "123",
            codeVerifier: "456",
            tokenEndpoint: "/token:bad",
            clientId: "foo",
            redirectUri: "bar"
        ) {
            XCTAssertNil($0)
            XCTAssertNotNil($1)
            expectFailed.fulfill()
        }

        wait(for: [expectOk, expectFailed], timeout: 1)
    }
}
