@testable import Logto
import XCTest

final class LogtoCoreTests: XCTestCase {
    let authorizationEndpoint = "https://logto.dev/oidc"
    let clientId = "foo"
    let codeVerifier = LogtoUtilities.generateCodeVerifier()
    let state = LogtoUtilities.generateState()
}
