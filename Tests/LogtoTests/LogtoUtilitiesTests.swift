@testable import Logto
import XCTest

final class LogtoUtilitiesTests: XCTestCase {
    func fromBase64(string: String) -> String? {
        guard let data = Data(base64Encoded: string) else {
            return nil
        }

        return String(data: data, encoding: .utf8)
    }
    
    func testGenerateState() throws {
        let verifier = LogtoUtilities.generateState()
        XCTAssertEqual(fromBase64(string: verifier)?.count, 64)
    }

    func testGenerateCodeVerifier() throws {
        let verifier = LogtoUtilities.generateCodeVerifier()
        XCTAssertEqual(fromBase64(string: verifier)?.count, 64)
    }
}
