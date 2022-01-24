@testable import LogtoClient
import XCTest

final class LogtoConfigTests: XCTestCase {
    func testLogtoConfig() throws {
        let config = LogtoConfig(endpoint: "foo", clientId: "bar", scope: .value("scope1"))
        XCTAssertEqual(config.scope, ["offline_access", "openid", "scope1"])
    }
}
