@testable import LogtoClient
import XCTest

extension LogtoClientTests {
    func testSignOutOk() async {
        let client = buildClient(withToken: true)
        let error = await client.signOut()

        XCTAssertNil(error)
        XCTAssertNil(client.refreshToken)
        XCTAssertNil(client.idToken)
        XCTAssertEqual(client.accessTokenMap.count, 0)
    }

    func testSignOutUnableToFetchOidcConfig() async {
        let client = buildClient(withOidcEndpoint: "/bad", withToken: true)
        let error = await client.signOut()

        XCTAssertEqual(error?.type, .unableToRevokeToken)
    }

    func testSignOutUnableToRevokeToken() async {
        let client = buildClient(withOidcEndpoint: "/oidc_config:bad", withToken: true)
        let error = await client.signOut()

        XCTAssertEqual(error?.type, .unableToRevokeToken)
        XCTAssertNil(client.refreshToken)
        XCTAssertNil(client.idToken)
        XCTAssertEqual(client.accessTokenMap.count, 0)
    }
}
