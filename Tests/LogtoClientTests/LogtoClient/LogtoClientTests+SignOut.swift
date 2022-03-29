@testable import LogtoClient
import XCTest

extension LogtoClientTests {
    func testSignOutOk() async throws {
        let client = buildClient(withToken: true)
        let error = try await client.signOut()

        XCTAssertNil(error)
        XCTAssertNil(client.refreshToken)
        XCTAssertNil(client.idToken)
        XCTAssertEqual(client.accessTokenMap.count, 0)
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
        let error = try await client.signOut()

        XCTAssertEqual(error?.type, .unableToRevokeToken)
        XCTAssertNil(client.refreshToken)
        XCTAssertNil(client.idToken)
        XCTAssertEqual(client.accessTokenMap.count, 0)
    }
}
