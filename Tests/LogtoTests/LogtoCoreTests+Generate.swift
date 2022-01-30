@testable import Logto
import XCTest

extension LogtoCoreTests {
    func testGenerateSignInUriFailure() throws {
        XCTAssertThrowsError(try LogtoCore.generateSignInUri(
            authorizationEndpoint: "???",
            clientId: "",
            redirectUri: "",
            codeChallenge: "",
            state: ""
        )) {
            XCTAssertEqual($0 as? LogtoErrors.UrlConstruction, LogtoErrors.UrlConstruction.invalidEndpoint)
        }
    }

    func validateBaseInformation(url: URL) throws {
        XCTAssertEqual(url.scheme, "https")
        XCTAssertEqual(url.host, "logto.dev")
        XCTAssertEqual(url.path, "/oidc")
    }

    func testGenerateSignInUri() throws {
        let codeChallenge = LogtoUtilities.generateCodeChallenge(codeVerifier: codeVerifier)

        let url = try LogtoCore.generateSignInUri(
            authorizationEndpoint: authorizationEndpoint,
            clientId: clientId,
            redirectUri: "logto://sign-in/redirect",
            codeChallenge: codeChallenge,
            state: state
        )
        try validateBaseInformation(url: url)
        XCTAssertEqual(
            url.query,
            "client_id=foo&redirect_uri=logto://sign-in/redirect&code_challenge=\(codeChallenge)&code_challenge_method=S256&state=\(state)&scope=offline_access%20openid&response_type=code&prompt=consent"
        )
    }

    func testGenerateSignInUriWithScope() throws {
        let codeChallenge = LogtoUtilities.generateCodeChallenge(codeVerifier: codeVerifier)

        let url1 = try LogtoCore.generateSignInUri(
            authorizationEndpoint: authorizationEndpoint,
            clientId: clientId,
            redirectUri: "logto://sign-in/redirect",
            codeChallenge: codeChallenge,
            state: state,
            scope: .value("foo")
        )
        try validateBaseInformation(url: url1)
        XCTAssertEqual(
            url1.query,
            "client_id=foo&redirect_uri=logto://sign-in/redirect&code_challenge=\(codeChallenge)&code_challenge_method=S256&state=\(state)&scope=foo%20offline_access%20openid&response_type=code&prompt=consent"
        )

        let url2 = try LogtoCore.generateSignInUri(
            authorizationEndpoint: authorizationEndpoint,
            clientId: clientId,
            redirectUri: "logto://sign-in/redirect",
            codeChallenge: codeChallenge,
            state: state,
            scope: .array(["foo", "bar"])
        )
        try validateBaseInformation(url: url2)
        XCTAssertEqual(
            url2.query,
            "client_id=foo&redirect_uri=logto://sign-in/redirect&code_challenge=\(codeChallenge)&code_challenge_method=S256&state=\(state)&scope=bar%20foo%20offline_access%20openid&response_type=code&prompt=consent"
        )
    }

    func testGenerateSignInUriWithResource() throws {
        let codeChallenge = LogtoUtilities.generateCodeChallenge(codeVerifier: codeVerifier)

        let url1 = try LogtoCore.generateSignInUri(
            authorizationEndpoint: authorizationEndpoint,
            clientId: clientId,
            redirectUri: "logto://sign-in/redirect",
            codeChallenge: codeChallenge,
            state: state,
            resource: .value("https://api.logto.dev/")
        )
        try validateBaseInformation(url: url1)
        XCTAssertEqual(
            url1.query,
            "client_id=foo&redirect_uri=logto://sign-in/redirect&code_challenge=\(codeChallenge)&code_challenge_method=S256&state=\(state)&scope=offline_access%20openid&response_type=code&prompt=consent&resource=https://api.logto.dev/"
        )

        let url2 = try LogtoCore.generateSignInUri(
            authorizationEndpoint: authorizationEndpoint,
            clientId: clientId,
            redirectUri: "logto://sign-in/redirect",
            codeChallenge: codeChallenge,
            state: state,
            resource: .array(["https://api.logto.dev/", "bar"])
        )
        try validateBaseInformation(url: url2)
        XCTAssertEqual(
            url2.query,
            "client_id=foo&redirect_uri=logto://sign-in/redirect&code_challenge=\(codeChallenge)&code_challenge_method=S256&state=\(state)&scope=offline_access%20openid&response_type=code&prompt=consent&resource=https://api.logto.dev/&resource=bar"
        )
    }

    func testGenerateSignOutUri() throws {
        XCTAssertThrowsError(try LogtoCore
            .generateSignOutUri(endSessionEndpoint: "???", idToken: "", postLogoutRedirectUri: nil)) {
                XCTAssertEqual(
                    $0 as? LogtoErrors.UrlConstruction,
                    LogtoErrors.UrlConstruction.invalidEndpoint
                )
            }

        let endSessionEndpoint = "https://logto.dev/oidc/session/end"
        let idToken = "foo"
        let postLogoutRedirectUri = "https://localhost"
        let url = try LogtoCore.generateSignOutUri(
            endSessionEndpoint: endSessionEndpoint,
            idToken: idToken,
            postLogoutRedirectUri: postLogoutRedirectUri
        )

        XCTAssertEqual(url.scheme, "https")
        XCTAssertEqual(url.host, "logto.dev")
        XCTAssertEqual(url.path, "/oidc/session/end")
        XCTAssertEqual(url.query, "id_token_hint=\(idToken)&post_logout_redirect_uri=\(postLogoutRedirectUri)")
    }
}
