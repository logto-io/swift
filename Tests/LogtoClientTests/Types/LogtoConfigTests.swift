@testable import LogtoClient
import XCTest

final class LogtoConfigTests: XCTestCase {
    func testLogtoConfig() throws {
        let config = try LogtoConfig(endpoint: "foo", appId: "bar", scopes: ["scope1"])
        XCTAssertEqual(config.scopes.sorted(), ["offline_access", "openid", "profile", "scope1"].sorted())
        XCTAssertTrue(config.prefersEphemeralWebBrowserSession)
    }

    func testLogtoConfigWithEphemeralWebBrowserSession() throws {
        let config = try LogtoConfig(
            endpoint: "foo",
            appId: "bar",
            prefersEphemeralWebBrowserSession: false
        )

        XCTAssertFalse(config.prefersEphemeralWebBrowserSession)
    }
}
