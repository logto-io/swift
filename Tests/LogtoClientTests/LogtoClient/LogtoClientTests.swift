@testable import LogtoClient
import LogtoMock
import XCTest

final class LogtoClientTests: XCTestCase {
    func buildClient(withOidcEndpoint endpoint: String = "/oidc_config:good", withToken: Bool = false) -> LogtoClient {
        let client = LogtoClient(
            useConfig: try! LogtoConfig(endpoint: endpoint, clientId: "foo"),
            session: NetworkSessionMock.shared
        )

        if withToken {
            client.refreshToken = "foo"
            client.idToken = "bar"
            client.accessTokenMap = [
                "scope@resource": AccessToken(token: "", scope: "", expiresAt: 1),
            ]
        }

        return client
    }
}
