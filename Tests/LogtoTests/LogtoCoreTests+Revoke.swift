@testable import Logto
import XCTest
import LogtoMock

extension LogtoCoreTests {
    func testRevokeToken() throws {
        let expectOk = expectation(description: "Revoke token OK")
        let expectFailed = expectation(description: "Revoke token failed")

        LogtoCore.revoke(
            useSession: NetworkSessionMock.shared,
            token: "123",
            revocationEndpoint: "/revoke:good",
            clientId: "foo"
        ) {
            XCTAssertNil($0)
            expectOk.fulfill()
        }

        LogtoCore.revoke(
            useSession: NetworkSessionMock.shared,
            token: "123",
            revocationEndpoint: "/revoke:bad",
            clientId: "foo"
        ) {
            XCTAssertNotNil($0)
            expectFailed.fulfill()
        }

        wait(for: [expectOk, expectFailed], timeout: 1)
    }
}
