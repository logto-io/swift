@testable import Logto
import LogtoMock
import XCTest

extension LogtoCoreTests {
    func testFetchOidcConfig() async throws {
        let config = try await LogtoCore.fetchOidcConfig(
            useSession: NetworkSessionMock.shared,
            uri: URL(string: "/oidc_config:good")!
        )
        XCTAssertNotNil(config)

        await LogtoCoreTests
            .assertThrows(try await LogtoCore
                .fetchOidcConfig(useSession: NetworkSessionMock.shared, uri: URL(string: "/bad")!))
    }

    func testFetchTokenByCode() async throws {
        let token = try await LogtoCore.fetchToken(
            useSession: NetworkSessionMock.shared,
            byAuthorizationCode: "123",
            codeVerifier: "456",
            tokenEndpoint: "/token:good",
            clientId: "foo",
            redirectUri: "bar"
        )
        XCTAssertNotNil(token)

        await LogtoCoreTests.assertThrows(try await LogtoCore.fetchToken(
            useSession: NetworkSessionMock.shared,
            byAuthorizationCode: "123",
            codeVerifier: "456",
            tokenEndpoint: "/token:bad",
            clientId: "foo",
            redirectUri: "bar"
        ))
    }

    func testFetchTokenByRefreshToken() async throws {
        let token = try await LogtoCore.fetchToken(
            useSession: NetworkSessionMock.shared,
            byRefreshToken: "123",
            tokenEndpoint: "/token:good",
            clientId: "foo",
            resource: "bar",
            scopes: ["baz"]
        )
        XCTAssertNotNil(token)

        await LogtoCoreTests.assertThrows(try await LogtoCore.fetchToken(
            useSession: NetworkSessionMock.shared,
            byRefreshToken: "123",
            tokenEndpoint: "/token:bad",
            clientId: "foo",
            resource: nil,
            scopes: []
        ))
    }

    func testFetchUserInfo() async throws {
        let info = try await LogtoCore.fetchUserInfo(
            useSession: NetworkSessionMock.shared,
            userInfoEndpoint: "/user",
            accessToken: "good"
        )
        XCTAssertNotNil(info)

        await LogtoCoreTests.assertThrows(try await LogtoCore.fetchUserInfo(
            useSession: NetworkSessionMock.shared,
            userInfoEndpoint: "/user",
            accessToken: "bad"
        ))
    }
}
