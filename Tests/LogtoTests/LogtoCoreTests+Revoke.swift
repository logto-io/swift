@testable import Logto
import LogtoMock
import XCTest

extension LogtoCoreTests {
    func testRevokeToken() async throws {
        try await LogtoCore.revoke(
            useSession: NetworkSessionMock.shared,
            token: "123",
            revocationEndpoint: "/revoke:good",
            clientId: "foo"
        )

        await LogtoCoreTests.assertThrows(try await LogtoCore.revoke(
            useSession: NetworkSessionMock.shared,
            token: "123",
            revocationEndpoint: "/revoke:bad",
            clientId: "foo"
        ))
    }
}
