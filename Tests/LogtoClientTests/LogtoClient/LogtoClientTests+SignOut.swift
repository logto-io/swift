@testable import LogtoClient
import LogtoMock
import XCTest

extension LogtoClientTests {
    func testSignOutOk() throws {
        let client = LogtoClient(
            useConfig: try LogtoConfig(endpoint: "/oidc_config:good", clientId: "foo"),
            session: NetworkSessionMock.shared
        )
        let expectOk = expectation(description: "Sign out OK")

        client.refreshToken = "foo"
        client.idToken = "bar"
        client.accessTokenMap = [
            "scope@resource": AccessToken(token: "", scope: "", expiresAt: 1)
        ]

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
        let client = LogtoClient(
            useConfig: try LogtoConfig(endpoint: "/bad", clientId: "foo"),
            session: NetworkSessionMock.shared
        )
        let expectFailure = expectation(description: "Sign out OK")

        client.refreshToken = "foo"
        client.idToken = "bar"
        client.accessTokenMap = [
            "scope@resource": AccessToken(token: "", scope: "", expiresAt: 1)
        ]

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
        let client = LogtoClient(
            useConfig: try LogtoConfig(endpoint: "/oidc_config:bad", clientId: "foo"),
            session: NetworkSessionMock.shared
        )
        let expectFailure = expectation(description: "Sign out OK")

        client.refreshToken = "foo"
        client.idToken = "bar"
        client.accessTokenMap = [
            "scope@resource": AccessToken(token: "", scope: "", expiresAt: 1)
        ]

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
