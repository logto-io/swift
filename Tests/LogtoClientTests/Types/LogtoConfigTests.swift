@testable import LogtoClient
import XCTest

final class LogtoConfigTests: XCTestCase {
    func testLogtoConfig() throws {
        let config = try LogtoConfig(endpoint: "foo", clientId: "bar", scopes: ["scope1"])
        XCTAssertEqual(config.scopes, ["offline_access", "openid", "scope1"])
    }
}
