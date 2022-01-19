@testable import Logto
import XCTest

extension LogtoCoreTests {
    func testFetchOidcConfig() throws {
        let expectOk = expectation(description: "Fetch OpenID config OK")
        let expectFailed = expectation(description: "Fetch OpenID config failed")

        LogtoCore.fetchOidcConfig(useSession: NetworkSessionMock.shared, endpoint: "OidcConfig:good") {
            XCTAssertNotNil($0)
            XCTAssertNil($1)
            expectOk.fulfill()
        }

        LogtoCore.fetchOidcConfig(useSession: NetworkSessionMock.shared, endpoint: "OidcConfig:bad") {
            XCTAssertNil($0)
            XCTAssertNotNil($1)
            expectFailed.fulfill()
        }

        wait(for: [expectOk, expectFailed], timeout: 1)
    }
}
