@testable import LogtoClient
import XCTest

extension LogtoClientTests {
    func testSignOutOk() async throws {
        let client = buildClient(withToken: true)
        let expectOk = expectation(description: "Sign out OK")

        try await client.signOut {
            XCTAssertNil($0)
            XCTAssertNil(client.refreshToken)
            XCTAssertNil(client.idToken)
            XCTAssertEqual(client.accessTokenMap.count, 0)
            expectOk.fulfill()
        }

        wait(for: [expectOk], timeout: 1)
    }

    func testSignOutUnableToFetchOidcConfig() async throws {
        let client = buildClient(withOidcEndpoint: "/bad", withToken: true)

        do {
            try await client.signOut()
        } catch let error as LogtoClient.Errors.OidcConfig {
            XCTAssertEqual(error.type, .unableToFetchOidcConfig)
            return
        }

        XCTFail()
    }

    func testSignOutUnableToRevokeToken() async throws {
        let client = buildClient(withOidcEndpoint: "/oidc_config:bad", withToken: true)
        let expectFailure = expectation(description: "Sign out failed")

        try await client.signOut {
            XCTAssertEqual(($0!).type, .unableToRevokeToken)
            XCTAssertNil(client.refreshToken)
            XCTAssertNil(client.idToken)
            XCTAssertEqual(client.accessTokenMap.count, 0)
            expectFailure.fulfill()
        }

        wait(for: [expectFailure], timeout: 1)
    }
}
