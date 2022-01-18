@testable import Logto
import XCTest

extension LogtoCoreTests {
    func testFetchOidcConfig() throws {
        LogtoCore.fetchOidcConfig(endpoint: "https://logto.dev/oidc/.well-known/openid-configuration") {
            print($0, $1)
        }
    }
}
