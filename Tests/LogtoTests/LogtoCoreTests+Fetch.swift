@testable import Logto
import XCTest

extension LogtoCoreTests {
    func testFetchOidcConfig() throws {
        let expectOk = expectation(description: "Fetch OpenID config OK")
        let expectFailed = expectation(description: "Fetch OpenID config failed")

        LogtoCore.fetchOidcConfig(useSession: NetworkSessionMock.shared, endpoint: "/oidc_config:good") {
            XCTAssertNotNil($0)
            XCTAssertNil($1)
            expectOk.fulfill()
        }

        LogtoCore.fetchOidcConfig(useSession: NetworkSessionMock.shared, endpoint: "/oidc_config:bad") {
            XCTAssertNil($0)
            XCTAssertNotNil($1)
            expectFailed.fulfill()
        }

        wait(for: [expectOk, expectFailed], timeout: 1)
    }

    func testFetchTokenByCode() throws {
        let expectOk = expectation(description: "Fetch token by code OK")
        let expectFailed = expectation(description: "Fetch token by code failed")

        LogtoCore.fetchToken(
            useSession: NetworkSessionMock.shared,
            byAuthorizationCode: "123",
            codeVerifier: "456",
            tokenEndpoint: "/token:good",
            clientId: "foo",
            redirectUri: "bar"
        ) {
            XCTAssertNotNil($0)
            XCTAssertNil($1)
            expectOk.fulfill()
        }

        LogtoCore.fetchToken(
            useSession: NetworkSessionMock.shared,
            byAuthorizationCode: "123",
            codeVerifier: "456",
            tokenEndpoint: "/token:bad",
            clientId: "foo",
            redirectUri: "bar"
        ) {
            XCTAssertNil($0)
            XCTAssertNotNil($1)
            expectFailed.fulfill()
        }

        wait(for: [expectOk, expectFailed], timeout: 1)
    }

    func testFetchUserInfo() throws {
        let expectOk = expectation(description: "Fetch user info OK")
        let expectFailed = expectation(description: "Fetch user info failed")

        LogtoCore.fetchUserInfo(
            useSession: NetworkSessionMock.shared,
            userInfoEndpoint: "/user",
            accessToken: "good"
        ) {
            XCTAssertNotNil($0)
            XCTAssertNil($1)
            expectOk.fulfill()
        }
        
        LogtoCore.fetchUserInfo(
            useSession: NetworkSessionMock.shared,
            userInfoEndpoint: "/user",
            accessToken: "bad"
        ) {
            XCTAssertNil($0)
            XCTAssertNotNil($1)
            expectFailed.fulfill()
        }
        
        wait(for: [expectOk, expectFailed], timeout: 1)
    }
            
    
    func testFetchTokenByRefreshToken() throws {
        let expectOk = expectation(description: "Fetch token by refresh token OK")
        let expectFailed = expectation(description: "Fetch token by refresh token failed")

        LogtoCore.fetchToken(
            useSession: NetworkSessionMock.shared,
            byRefreshToken: "123",
            tokenEndpoint: "/token:good",
            clientId: "foo",
            resource: "bar",
            scope: .value("baz")
        ) {
            XCTAssertNotNil($0)
            XCTAssertNil($1)
            expectOk.fulfill()
        }

        LogtoCore.fetchToken(
            useSession: NetworkSessionMock.shared,
            byRefreshToken: "123",
            tokenEndpoint: "/token:bad",
            clientId: "foo"
        ) {
            XCTAssertNil($0)
            XCTAssertNotNil($1)
            expectFailed.fulfill()
        }

        wait(for: [expectOk, expectFailed], timeout: 1)
    }
}
