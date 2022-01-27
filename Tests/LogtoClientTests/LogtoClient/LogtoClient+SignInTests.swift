@testable import LogtoClient
import LogtoMock
import XCTest

extension LogtoClientTests {
    func testFetchOidcConfigOk() throws {
        let client = LogtoClient(
            useConfig: try LogtoConfig(endpoint: "/oidc_config:good", clientId: "foo"),
            session: NetworkSessionMock.shared
        )
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

    func testFetchOidcConfigFailed() throws {
        let client = LogtoClient(
            useConfig: try LogtoConfig(endpoint: "/oidc_config:bad", clientId: "foo"),
            session: NetworkSessionMock.shared
        )
        let expectFailed = expectation(description: "Fetch OpenID config failed")

        XCTAssertNil(client.oidcConfig)

        client.fetchOidcConfig {
            XCTAssertNil($0)
            XCTAssertNotNil($1)
            XCTAssertNil(client.oidcConfig)
            expectFailed.fulfill()
        }

        wait(for: [expectFailed], timeout: 1)
    }
}
