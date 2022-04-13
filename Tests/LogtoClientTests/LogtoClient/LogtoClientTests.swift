import Logto
@testable import LogtoClient
import LogtoMock
import XCTest

final class LogtoClientTests: XCTestCase {
    let initialRefreshToken = "foo"
    let initialIdToken = "bar"

    func buildClient(withOidcEndpoint endpoint: String = "/oidc_config:good", withToken: Bool = false) -> LogtoClient {
        let client = LogtoClient(
            useConfig: try! LogtoConfig(endpoint: endpoint, clientId: "foo", usingPersistStorage: false),
            session: NetworkSessionMock.shared
        )

        if withToken {
            client.refreshToken = initialRefreshToken
            client.idToken = initialIdToken
            client.accessTokenMap = [
                "scope@resource": AccessToken(token: "", scope: "", expiresAt: 1),
            ]
        }

        return client
    }

    func testIsAuthenticated() {
        let client = buildClient()

        XCTAssertFalse(client.isAuthenticated)

        client.idToken = "foo"
        XCTAssertTrue(client.isAuthenticated)
    }

    func testGetIdTokenClaims() {
        let client = buildClient()

        XCTAssertThrowsError(try client.getIdTokenClaims()) {
            XCTAssertEqual($0 as? LogtoClient.Errors.IdToken, .notAuthenticated)
        }

        client
            .idToken =
            "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxMjM0NTY3ODkwIiwiYXVkIjoiZm9vIiwiaXNzIjoiYmFyIiwibmFtZSI6IkpvaG4gRG9lIiwiaWF0IjoxNTE2MjM5MDIyLCJleHAiOjE1MTYyMzkwMjJ9.t2LDedv_3AGjdOnrZuBKl83HfnD1aapuSWbPVIhwecc"

        XCTAssertEqual(
            try! client.getIdTokenClaims(),
            try! JSONDecoder().decode(IdTokenClaims.self, from: Data("""
                {
                    "sub": "1234567890",
                    "aud": "foo",
                    "iss": "bar",
                    "iat": 1516239022,
                    "exp": 1516239022
                }
            """.utf8))
        )
    }

    func testUsingPersistStorage() {
        let client = LogtoClient(
            useConfig: try! LogtoConfig(endpoint: "/", clientId: "foo"),
            session: NetworkSessionMock.shared
        )

        XCTAssertNotNil(client.keychain)
    }
}
