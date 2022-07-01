@testable import Logto
import XCTest

extension LogtoCoreTests {
    func testGenerateSignInUriFailure() throws {
        XCTAssertThrowsError(try LogtoCore.generateSignInUri(
            authorizationEndpoint: "???",
            clientId: "",
            redirectUri: URL(string: "foo")!,
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

    func sortByName(a: URLQueryItem, b: URLQueryItem) -> Bool {
        a.name < b.name || a.name == b.name && (a.value ?? "") < (b.value ?? "")
    }

    func validate(url: URL, queryItems: [URLQueryItem]) -> Bool {
        let components = URLComponents(url: url, resolvingAgainstBaseURL: true)

        let itemsA = components?.queryItems?.sorted(by: sortByName) ?? []
        let itemsB = queryItems.sorted(by: sortByName)

        return itemsA.elementsEqual(itemsB) {
            switch $0.name {
            case "scope":
                return ($0.value?.split(separator: " ") ?? []).sorted() == ($1.value?.split(separator: " ") ?? [])
                    .sorted()
            default:
                return $0 == $1
            }
        }
    }

    func testGenerateSignInUri() throws {
        let codeChallenge = LogtoUtilities.generateCodeChallenge(codeVerifier: codeVerifier)

        let url = try LogtoCore.generateSignInUri(
            authorizationEndpoint: authorizationEndpoint,
            clientId: clientId,
            redirectUri: URL(string: "logto://sign-in/redirect")!,
            codeChallenge: codeChallenge,
            state: state
        )
        try validateBaseInformation(url: url)

        XCTAssertTrue(validate(url: url, queryItems: [
            URLQueryItem(name: "client_id", value: "foo"),
            URLQueryItem(name: "redirect_uri", value: "logto://sign-in/redirect"),
            URLQueryItem(name: "code_challenge", value: codeChallenge),
            URLQueryItem(name: "code_challenge_method", value: "S256"),
            URLQueryItem(name: "state", value: state),
            URLQueryItem(name: "scope", value: "offline_access openid profile"),
            URLQueryItem(name: "response_type", value: "code"),
            URLQueryItem(name: "prompt", value: "consent"),
        ]))
    }

    func testGenerateSignInUriWithScope() throws {
        let codeChallenge = LogtoUtilities.generateCodeChallenge(codeVerifier: codeVerifier)

        let url1 = try LogtoCore.generateSignInUri(
            authorizationEndpoint: authorizationEndpoint,
            clientId: clientId,
            redirectUri: URL(string: "logto://sign-in/redirect")!,
            codeChallenge: codeChallenge,
            state: state,
            scopes: ["foo"]
        )
        try validateBaseInformation(url: url1)

        XCTAssertTrue(validate(url: url1, queryItems: [
            URLQueryItem(name: "client_id", value: "foo"),
            URLQueryItem(name: "redirect_uri", value: "logto://sign-in/redirect"),
            URLQueryItem(name: "code_challenge", value: codeChallenge),
            URLQueryItem(name: "code_challenge_method", value: "S256"),
            URLQueryItem(name: "state", value: state),
            URLQueryItem(name: "scope", value: "foo offline_access openid profile"),
            URLQueryItem(name: "response_type", value: "code"),
            URLQueryItem(name: "prompt", value: "consent"),
        ]))

        let url2 = try LogtoCore.generateSignInUri(
            authorizationEndpoint: authorizationEndpoint,
            clientId: clientId,
            redirectUri: URL(string: "logto://sign-in/redirect")!,
            codeChallenge: codeChallenge,
            state: state,
            scopes: ["foo", "bar"]
        )
        try validateBaseInformation(url: url2)

        XCTAssertTrue(validate(url: url2, queryItems: [
            URLQueryItem(name: "client_id", value: "foo"),
            URLQueryItem(name: "redirect_uri", value: "logto://sign-in/redirect"),
            URLQueryItem(name: "code_challenge", value: codeChallenge),
            URLQueryItem(name: "code_challenge_method", value: "S256"),
            URLQueryItem(name: "state", value: state),
            URLQueryItem(name: "scope", value: "foo bar offline_access openid profile"),
            URLQueryItem(name: "response_type", value: "code"),
            URLQueryItem(name: "prompt", value: "consent"),
        ]))
    }

    func testGenerateSignInUriWithResource() throws {
        let codeChallenge = LogtoUtilities.generateCodeChallenge(codeVerifier: codeVerifier)

        let url1 = try LogtoCore.generateSignInUri(
            authorizationEndpoint: authorizationEndpoint,
            clientId: clientId,
            redirectUri: URL(string: "logto://sign-in/redirect")!,
            codeChallenge: codeChallenge,
            state: state,
            resources: ["https://api.logto.dev"]
        )
        try validateBaseInformation(url: url1)

        XCTAssertTrue(validate(url: url1, queryItems: [
            URLQueryItem(name: "client_id", value: "foo"),
            URLQueryItem(name: "redirect_uri", value: "logto://sign-in/redirect"),
            URLQueryItem(name: "code_challenge", value: codeChallenge),
            URLQueryItem(name: "code_challenge_method", value: "S256"),
            URLQueryItem(name: "state", value: state),
            URLQueryItem(name: "scope", value: "offline_access openid profile"),
            URLQueryItem(name: "response_type", value: "code"),
            URLQueryItem(name: "prompt", value: "consent"),
            URLQueryItem(name: "resource", value: "https://api.logto.dev"),
        ]))

        let url2 = try LogtoCore.generateSignInUri(
            authorizationEndpoint: authorizationEndpoint,
            clientId: clientId,
            redirectUri: URL(string: "logto://sign-in/redirect")!,
            codeChallenge: codeChallenge,
            state: state,
            resources: ["https://api.logto.dev", "bar"]
        )
        try validateBaseInformation(url: url2)

        XCTAssertTrue(validate(url: url2, queryItems: [
            URLQueryItem(name: "client_id", value: "foo"),
            URLQueryItem(name: "redirect_uri", value: "logto://sign-in/redirect"),
            URLQueryItem(name: "code_challenge", value: codeChallenge),
            URLQueryItem(name: "code_challenge_method", value: "S256"),
            URLQueryItem(name: "state", value: state),
            URLQueryItem(name: "scope", value: "offline_access openid profile"),
            URLQueryItem(name: "response_type", value: "code"),
            URLQueryItem(name: "prompt", value: "consent"),
            URLQueryItem(name: "resource", value: "https://api.logto.dev"),
            URLQueryItem(name: "resource", value: "bar"),
        ]))
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
        XCTAssertTrue(validate(url: url, queryItems: [
            URLQueryItem(name: "id_token_hint", value: idToken),
            URLQueryItem(name: "post_logout_redirect_uri", value: postLogoutRedirectUri),
        ]))
    }
}
