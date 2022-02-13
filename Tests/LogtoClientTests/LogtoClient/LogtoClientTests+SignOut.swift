@testable import LogtoClient
import XCTest

extension LogtoClientTests {
    func testSignOutOk() throws {
        let client = buildClient(withToken: true)
        let expectOk = expectation(description: "Sign out OK")

        client.signOut {
            XCTAssertNil($0)
            XCTAssertNil(client.refreshToken)
            XCTAssertNil(client.idToken)
            XCTAssertEqual(client.accessTokenMap.count, 0)
            expectOk.fulfill()
        }

        wait(for: [expectOk], timeout: 1)
    }

    func testSignOutUnableToFetchOidcConfig() throws {
        let client = buildClient(withOidcEndpoint: "/bad", withToken: true)
        let expectFailure = expectation(description: "Sign out OK")

        client.signOut {
            XCTAssertEqual(($0!).type, .unableToFetchOidcConfig)
            XCTAssertNil(client.refreshToken)
            XCTAssertNil(client.idToken)
            XCTAssertEqual(client.accessTokenMap.count, 0)
            expectFailure.fulfill()
        }

        wait(for: [expectFailure], timeout: 1)
    }

    func testSignOutUnableToRevokeToken() throws {
        let client = buildClient(withOidcEndpoint: "/oidc_config:bad", withToken: true)
        let expectFailure = expectation(description: "Sign out OK")

        client.signOut {
            XCTAssertEqual(($0!).type, .unableToRevokeToken)
            XCTAssertNil(client.refreshToken)
            XCTAssertNil(client.idToken)
            XCTAssertEqual(client.accessTokenMap.count, 0)
            expectFailure.fulfill()
        }

        wait(for: [expectFailure], timeout: 1)
    }
}
