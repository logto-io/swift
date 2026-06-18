@testable import Logto
import XCTest

extension LogtoCoreTests {
    func testVerifyAndParseSignInCallbackUri() throws {
        let state = "123"
        let code = "456"
        let callbackUri = try XCTUnwrap(URL(string: "logto-dev://callback?state=\(state)&code=\(code)"))
        let callbackUriWithError =
            try XCTUnwrap(URL(string: "logto-dev://callback?state=\(state)&code=\(code)&error=foo"))
        let callbackUriWithNoCode = try XCTUnwrap(URL(string: "logto-dev://callback?state=\(state)"))
        let redirectUri = try XCTUnwrap(URL(string: "logto-dev://callback"))

        XCTAssertThrowsError(try LogtoCore
            .verifyAndParseSignInCallbackUri(
                XCTUnwrap(URL(string: "aaa")),
                redirectUri: redirectUri,
                state: state
            )) {
                XCTAssertEqual($0 as? LogtoErrors.UriVerification, LogtoErrors.UriVerification.redirectUriMismatched)
            }

        XCTAssertThrowsError(try LogtoCore
            .verifyAndParseSignInCallbackUri(redirectUri, redirectUri: redirectUri, state: state))
        {
            XCTAssertEqual($0 as? LogtoErrors.UriVerification, LogtoErrors.UriVerification.stateMismatched)
        }

        XCTAssertThrowsError(try LogtoCore
            .verifyAndParseSignInCallbackUri(callbackUriWithError, redirectUri: redirectUri, state: state))
        {
            XCTAssertEqual(
                $0 as? LogtoErrors.UriVerification,
                LogtoErrors.UriVerification.errorItemFound(items: [URLQueryItem(name: "error", value: "foo")])
            )
        }

        XCTAssertThrowsError(try LogtoCore
            .verifyAndParseSignInCallbackUri(callbackUriWithNoCode, redirectUri: redirectUri, state: state))
        {
            XCTAssertEqual($0 as? LogtoErrors.UriVerification, LogtoErrors.UriVerification.missingCode)
        }

        XCTAssertEqual(
            try LogtoCore.verifyAndParseSignInCallbackUri(callbackUri, redirectUri: redirectUri, state: state),
            "456"
        )
    }
}
