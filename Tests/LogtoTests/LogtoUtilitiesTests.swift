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

    func testGenerateCodeChallenge() throws {
        XCTAssertEqual(
            LogtoUtilities.generateCodeChallenge(codeVerifier: "tO6MabnMFRAatnlMa1DdSstypzzkgalL1-k8Hr_GdfTj-VXGiEACqAkSkDhFuAuD8FOU8lMishaXjt29Xt2Oww"),
            "0K3SLeGlNNzFswYJjcVzcN4C76m_8NZORxFJLBJWGwg"
        )
        XCTAssertEqual(
            LogtoUtilities.generateCodeChallenge(codeVerifier: "ipK7uh7F41nJyYY4RZQzEwBwBTd-BlXSO4W8q0tK5VA"),
            "C51JGVPSnuLTTumLt6X5w2JAL_kBaeqHON3KPIviYaU"
        )
        XCTAssertEqual(LogtoUtilities.generateCodeChallenge(codeVerifier: "Á"), "p3yvZiKYauPicLIDZ0W1peDz4Z9KFC-9uxtDfoO1KOQ")
        XCTAssertEqual(LogtoUtilities.generateCodeChallenge(codeVerifier: "🚀"), "67wLKHDrMj8rbP-lxJPO74GufrNq_HPU4DZzAWMdrsU")
    }
    
    func testDecodeIdToken() throws {
        XCTAssertEqual(try LogtoUtilities.decodeIdToken("eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxMjM0NTY3ODkwIiwibmFtZSI6IkpvaG4gRG9lIiwiYXRfaGFzaCI6ImZvbyIsImF1ZCI6ImJhciIsImV4cCI6MTUxNjIzOTAyMSwiaWF0IjoxNTE2MjM5MDIyLCJpc3MiOiJodHRwczovL2xvZ3RvLmRldiJ9.sJMMInlklGgbSOeOa71_uhoUvTLXDFq4jHQ1Bu81GyE"), IdTokenClaims(sub: "1234567890", atHash: "foo", aud: "bar", exp: 1516239021, iat: 1516239022, iss: "https://logto.dev"))
        XCTAssertThrowsError(try LogtoUtilities.decodeIdToken("eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxMjM0NTY3ODkwIiwibmFtZSI6IkpvaG4gRG9lIiwiaWF0IjoxNTE2MjM5MDIyfQ.SflKxwRJSMeKKF2QT4fwpMeJf36POk6yJV_adQssw5c"))
    }
}
