import Logto
@testable import LogtoClient
import LogtoMock
import XCTest

class LogtoSocialPluginMock: LogtoSocialPlugin {
    let connectorPlatform: LogtoSocialPluginPlatform = .native
    let connectorTarget: String? = "target"
    let urlSchemes = ["mock"]

    func start(_: LogtoSocialPluginConfiguration) {}

    func handle(url: URL) -> Bool {
        urlSchemes.contains(url.scheme!)
    }
}

class LogtoClientMockHandleUrl: LogtoClient {
    var handleUrlCalled = false

    override func handle(url _: URL) -> Bool {
        handleUrlCalled = true
        return true
    }
}

final class LogtoClientTests: XCTestCase {
    let initialRefreshToken = "foo"
    let initialIdToken = "bar"

    func buildClient(withOidcEndpoint endpoint: String = "/oidc_config:good", withToken: Bool = false) -> LogtoClient {
        let client = LogtoClient(
            useConfig: try! LogtoConfig(endpoint: endpoint, appId: "foo", usingPersistStorage: false),
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

    func testStaticHandleUrl() {
        let appId = "foo"
        let url = URL(string: "bar")!
        var called = false

        let handle: (Notification) -> Void = { notification in
            let object = notification.object as! LogtoClient.NotificationObject
            XCTAssertEqual(object.appId, appId)
            XCTAssertEqual(object.url, url)
            called = true
        }

        NotificationCenter.default.addObserver(
            forName: LogtoClient.HandleNotification,
            object: nil,
            queue: nil,
            using: handle
        )

        LogtoClient.handle(forAppId: appId, url: url)
        XCTAssertTrue(called)
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
            XCTAssertEqual($0 as? LogtoClientErrors.IdToken, .notAuthenticated)
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
            useConfig: try! LogtoConfig(endpoint: "/", appId: "foo"),
            session: NetworkSessionMock.shared
        )

        XCTAssertNotNil(client.keychain)
    }

    func testHandleUrl() {
        let client = LogtoClient(
            useConfig: try! LogtoConfig(endpoint: "/", appId: "test-handle-url"),
            socialPlugins: [LogtoSocialPluginMock()]
        )

        XCTAssertTrue(client.handle(url: URL(string: "mock://foo")!))
    }

    func testHandleWrongNotification() {
        let client = LogtoClientMockHandleUrl(
            useConfig: try! LogtoConfig(endpoint: "/", appId: "test-handle-url"),
            socialPlugins: [LogtoSocialPluginMock()]
        )

        client.handle(notification: Notification(name: LogtoClient.HandleNotification))
        XCTAssertFalse(client.handleUrlCalled)
    }
}
