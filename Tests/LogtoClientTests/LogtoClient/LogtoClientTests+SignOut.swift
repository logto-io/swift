@testable import LogtoClient
import LogtoMock
import XCTest

extension LogtoClientTests {
    func buildClient(withOidcEndpoint endpoint: String = "/oidc_config:good") -> LogtoClient {
        let client = LogtoClient(
            useConfig: try! LogtoConfig(endpoint: endpoint, clientId: "foo"),
            session: NetworkSessionMock.shared
        )

        client.refreshToken = "foo"
        client.idToken = "bar"
        client.accessTokenMap = [
            "scope@resource": AccessToken(token: "", scope: "", expiresAt: 1),
        ]

        return client
    }

    func testSignOutOk() throws {
        let client = buildClient()
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
        let client = buildClient(withOidcEndpoint: "/bad")
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
        let client = buildClient(withOidcEndpoint: "/oidc_config:bad")
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
