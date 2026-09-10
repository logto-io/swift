import Logto
@testable import LogtoClient
import XCTest

final class LogtoConfigTests: XCTestCase {
    func testLogtoConfig() throws {
        let config = try LogtoConfig(endpoint: "foo", appId: "bar", scopes: ["scope1"])
        XCTAssertEqual(config.scopes.sorted(), ["offline_access", "openid", "profile", "scope1"].sorted())
        XCTAssertFalse(config.prefersEphemeralWebBrowserSession)
        XCTAssertEqual(config.idTokenVerification, IdTokenVerificationOptions())
        XCTAssertEqual(config.idTokenVerification.clockTolerance, LogtoUtilities.defaultIdTokenClockTolerance)
    }

    func testLogtoConfigWithEphemeralWebBrowserSession() throws {
        let config = try LogtoConfig(
            endpoint: "foo",
            appId: "bar",
            prefersEphemeralWebBrowserSession: true
        )

        XCTAssertTrue(config.prefersEphemeralWebBrowserSession)
    }

    func testLogtoConfigWithIdTokenVerification() throws {
        let idTokenVerification = IdTokenVerificationOptions(clockTolerance: 600)
        let config = try LogtoConfig(
            endpoint: "foo",
            appId: "bar",
            idTokenVerification: idTokenVerification
        )

        XCTAssertEqual(config.idTokenVerification, idTokenVerification)
    }

    func testLogtoConfigWithInvalidClockTolerance() {
        for clockTolerance: TimeInterval in [0, -1, .nan, .infinity] {
            XCTAssertThrowsError(try LogtoConfig(
                endpoint: "foo",
                appId: "bar",
                idTokenVerification: IdTokenVerificationOptions(clockTolerance: clockTolerance)
            )) {
                XCTAssertEqual($0 as? LogtoClientErrors.Config, .invalidClockTolerance)
            }
        }
    }
}
