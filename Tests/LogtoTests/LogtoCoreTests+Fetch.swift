@testable import Logto
import XCTest

private extension LogtoCore {
    static func fetchOidcConfig(endpoint: String, completion: @escaping (OidcConfigResponse?, Error?) -> Void) {
        switch endpoint {
        case "good":
            completion(OidcConfigResponse(
                authorizationEndpoint: "https://logto.dev/oidc/auth",
                tokenEndpoint: "https://logto.dev/oidc/token",
                endSessionEndpoint: "https://logto.dev/oidc/session/end",
                revocationEndpoint: "https://logto.dev/oidc/token/revocation",
                jwksUri: "https://logto.dev/oidc/jwks",
                issuer: "http://localhost:443/oidc"
            ), nil)
        default:
            completion(nil, LogtoErrors.Request.noResponseData)
        }
    }
}

extension LogtoCoreTests {
    func testFetchOidcConfig() throws {
        let expectOk = expectation(description: "Fetch OpenID config OK")
        let expectFailed = expectation(description: "Fetch OpenID config failed")

        LogtoCore.fetchOidcConfig(endpoint: "good") {
            XCTAssertNotNil($0)
            XCTAssertNil($1)
            expectOk.fulfill()
        }

        LogtoCore.fetchOidcConfig(endpoint: "bad") {
            XCTAssertNil($0)
            XCTAssertNotNil($1)
            expectFailed.fulfill()
        }

        wait(for: [expectOk, expectFailed], timeout: 1)
    }
}
