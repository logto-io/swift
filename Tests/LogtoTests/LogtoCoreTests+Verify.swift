@testable import Logto
import XCTest

extension LogtoCoreTests {
    func testVerifyAndParseSignInCallbackUri() throws {
        let state = "123"
        let code = "456"
        let callbackUri = "logto-dev://callback?state=\(state)&code=\(code)"
        let redirectUri = "logto-dev://callback"

        XCTAssertThrowsError(try LogtoCore
            .verifyAndParseSignInCallbackUri("aaa", redirectUri: redirectUri, state: state)) {
                XCTAssertEqual($0 as? LogtoErrors.UriVerification, LogtoErrors.UriVerification.redirectUriMismatched)
            }

        XCTAssertThrowsError(try LogtoCore
            .verifyAndParseSignInCallbackUri(redirectUri, redirectUri: redirectUri, state: state)) {
                XCTAssertEqual($0 as? LogtoErrors.UriVerification, LogtoErrors.UriVerification.stateMismatched)
            }

        XCTAssertThrowsError(try LogtoCore
            .verifyAndParseSignInCallbackUri(callbackUri + "&error=foo", redirectUri: redirectUri, state: state)) {
                XCTAssertEqual(
                    $0 as? LogtoErrors.UriVerification,
                    LogtoErrors.UriVerification.errorItemFound(items: [URLQueryItem(name: "error", value: "foo")])
                )
            }

        XCTAssertThrowsError(try LogtoCore
            .verifyAndParseSignInCallbackUri(redirectUri + "?state=123", redirectUri: redirectUri, state: state)) {
                XCTAssertEqual($0 as? LogtoErrors.UriVerification, LogtoErrors.UriVerification.missingCode)
            }

        XCTAssertEqual(
            try LogtoCore.verifyAndParseSignInCallbackUri(callbackUri, redirectUri: redirectUri, state: state),
            "456"
        )
    }
}
