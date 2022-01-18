@testable import Logto
import XCTest

final class LogtoCoreTests: XCTestCase {
    let authorizationEndpoint = "https://logto.dev/oidc"
    let clientId = "foo"
    let codeVerifier = LogtoUtilities.generateCodeVerifier()
    let state = LogtoUtilities.generateState()

    func testGenerateSignInUrlFailure() throws {
        XCTAssertThrowsError(try LogtoCore.generateSignInUrl(authorizationEndpoint: "???", clientId: "", redirectUri: "", codeChallenge: "", state: "")) {
            XCTAssertEqual($0 as? LogtoErrors.UrlConstruction, LogtoErrors.UrlConstruction.invalidAuthorizationEndpoint)
        }
    }

    func validateBaseInformation(url: URL) throws {
        XCTAssertEqual(url.scheme, "https")
        XCTAssertEqual(url.host, "logto.dev")
        XCTAssertEqual(url.path, "/oidc")
    }

    func testGenerateSignInUrl() throws {
        let codeChallenge = LogtoUtilities.generateCodeChallenge(codeVerifier: codeVerifier)

        let url = try LogtoCore.generateSignInUrl(authorizationEndpoint: authorizationEndpoint, clientId: clientId, redirectUri: "logto://sign-in/redirect", codeChallenge: codeChallenge, state: state)
        try validateBaseInformation(url: url)
        XCTAssertEqual(url.query, "client_id=foo&redirect_uri=logto://sign-in/redirect&code_challenge=\(codeChallenge)&code_challenge_method=S256&state=\(state)&response_type=authorization_code&prompt=consent")
    }

    func testGenerateSignInUrlWithScope() throws {
        let codeChallenge = LogtoUtilities.generateCodeChallenge(codeVerifier: codeVerifier)

        let url1 = try LogtoCore.generateSignInUrl(authorizationEndpoint: authorizationEndpoint, clientId: clientId, redirectUri: "logto://sign-in/redirect", codeChallenge: codeChallenge, state: state, scope: .value("foo"))
        try validateBaseInformation(url: url1)
        XCTAssertEqual(url1.query, "client_id=foo&redirect_uri=logto://sign-in/redirect&code_challenge=\(codeChallenge)&code_challenge_method=S256&state=\(state)&scope=foo&response_type=authorization_code&prompt=consent")

        let url2 = try LogtoCore.generateSignInUrl(authorizationEndpoint: authorizationEndpoint, clientId: clientId, redirectUri: "logto://sign-in/redirect", codeChallenge: codeChallenge, state: state, scope: .array(["foo", "bar"]))
        try validateBaseInformation(url: url2)
        XCTAssertEqual(url2.query, "client_id=foo&redirect_uri=logto://sign-in/redirect&code_challenge=\(codeChallenge)&code_challenge_method=S256&state=\(state)&scope=foo%20bar&response_type=authorization_code&prompt=consent")
    }

    func testGenerateSignInUrlWithResource() throws {
        let codeChallenge = LogtoUtilities.generateCodeChallenge(codeVerifier: codeVerifier)

        let url1 = try LogtoCore.generateSignInUrl(authorizationEndpoint: authorizationEndpoint, clientId: clientId, redirectUri: "logto://sign-in/redirect", codeChallenge: codeChallenge, state: state, resource: .value("https://api.logto.dev/"))
        try validateBaseInformation(url: url1)
        XCTAssertEqual(url1.query, "client_id=foo&redirect_uri=logto://sign-in/redirect&code_challenge=\(codeChallenge)&code_challenge_method=S256&state=\(state)&response_type=authorization_code&prompt=consent&resource=https://api.logto.dev/")

        let url2 = try LogtoCore.generateSignInUrl(authorizationEndpoint: authorizationEndpoint, clientId: clientId, redirectUri: "logto://sign-in/redirect", codeChallenge: codeChallenge, state: state, resource: .array(["https://api.logto.dev/", "bar"]))
        try validateBaseInformation(url: url2)
        XCTAssertEqual(url2.query, "client_id=foo&redirect_uri=logto://sign-in/redirect&code_challenge=\(codeChallenge)&code_challenge_method=S256&state=\(state)&response_type=authorization_code&prompt=consent&resource=https://api.logto.dev/&resource=bar")
    }
}
