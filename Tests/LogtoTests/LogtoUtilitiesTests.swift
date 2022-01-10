@testable import Logto
import XCTest

final class LogtoUtilitiesTests: XCTestCase {
    func testGenerateState() throws {
        let state = LogtoUtilities.generateState()
        XCTAssertTrue(state.isUrlSafe)
        XCTAssertEqual(Data.fromUrlSafeBase64(string: state)?.count, 64)
    }

    func testGenerateCodeVerifier() throws {
        let verifier = LogtoUtilities.generateCodeVerifier()
        XCTAssertTrue(verifier.isUrlSafe)
        XCTAssertEqual(Data.fromUrlSafeBase64(string: verifier)?.count, 64)
    }
}
