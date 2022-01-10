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
            try LogtoUtilities.generateCodeChallenge(codeVerifier: "tO6MabnMFRAatnlMa1DdSstypzzkgalL1-k8Hr_GdfTj-VXGiEACqAkSkDhFuAuD8FOU8lMishaXjt29Xt2Oww"),
            "0K3SLeGlNNzFswYJjcVzcN4C76m_8NZORxFJLBJWGwg"
        )
        XCTAssertEqual(
            try LogtoUtilities.generateCodeChallenge(codeVerifier: "ipK7uh7F41nJyYY4RZQzEwBwBTd-BlXSO4W8q0tK5VA"),
            "C51JGVPSnuLTTumLt6X5w2JAL_kBaeqHON3KPIviYaU"
        )
        XCTAssertEqual(try LogtoUtilities.generateCodeChallenge(codeVerifier: "Á"), "p3yvZiKYauPicLIDZ0W1peDz4Z9KFC-9uxtDfoO1KOQ")
        XCTAssertEqual(try LogtoUtilities.generateCodeChallenge(codeVerifier: "🚀"), "67wLKHDrMj8rbP-lxJPO74GufrNq_HPU4DZzAWMdrsU")
    }
}
