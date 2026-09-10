import Logto
@testable import LogtoClient
import XCTest

final class IdTokenVerificationOptionsTests: XCTestCase {
    func testDefaultClockTolerance() {
        XCTAssertEqual(IdTokenVerificationOptions.defaultClockTolerance, 300)
        XCTAssertEqual(IdTokenVerificationOptions().clockTolerance, LogtoUtilities.defaultIdTokenClockTolerance)
    }

    func testCustomClockTolerance() {
        XCTAssertEqual(IdTokenVerificationOptions(clockTolerance: 600).clockTolerance, 600)
    }
}
