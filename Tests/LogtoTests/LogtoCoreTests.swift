@testable import Logto
import XCTest

final class LogtoCoreTests: XCTestCase {
    let authorizationEndpoint = "https://logto.dev/oidc"
    let clientId = "foo"
    let codeVerifier = LogtoUtilities.generateCodeVerifier()
    let state = LogtoUtilities.generateState()

    static func assertThrows<T>(_ expression: @autoclosure () async throws -> T) async {
        do {
            _ = try await expression()
        } catch {
            return
        }
        XCTFail()
    }
}
