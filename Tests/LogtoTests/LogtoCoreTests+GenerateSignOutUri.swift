@testable import Logto
import XCTest

extension LogtoCoreTests {
    func testGenerateSignOutUri() throws {
        XCTAssertThrowsError(try LogtoCore.generateSignOutUri(endSessionEndpoint: "???", idToken: "", postLogoutRedirectUri: nil)) {
            XCTAssertEqual($0 as? LogtoErrors.UrlConstruction, LogtoErrors.UrlConstruction.invalidAuthorizationEndpoint)
        }
        
        let endSessionEndpoint = "https://logto.dev/oidc/session/end"
        let idToken = "foo"
        let postLogoutRedirectUri = "https://localhost"
        let url = try LogtoCore.generateSignOutUri(endSessionEndpoint: endSessionEndpoint, idToken: idToken, postLogoutRedirectUri: postLogoutRedirectUri)
        
        XCTAssertEqual(url.scheme, "https")
        XCTAssertEqual(url.host, "logto.dev")
        XCTAssertEqual(url.path, "/oidc/session/end")
        XCTAssertEqual(url.query, "id_token_hint=\(idToken)&post_logout_redirect_uri=\(postLogoutRedirectUri)")
    }
}
