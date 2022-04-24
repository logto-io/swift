@testable import LogtoClient
import XCTest

final class LogtoConfigTests: XCTestCase {
    func testLogtoConfig() throws {
        let config = try LogtoConfig(endpoint: "foo", appId: "bar", scopes: ["scope1"])
        XCTAssertEqual(config.scopes.sorted(), ["offline_access", "openid", "scope1"].sorted())
    }
}
