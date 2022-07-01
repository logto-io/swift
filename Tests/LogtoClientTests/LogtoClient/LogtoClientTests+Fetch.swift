import Logto
@testable import LogtoClient
import XCTest

extension LogtoClientTests {
    func testFetchOidcConfigOk() async throws {
        let client = buildClient()

        XCTAssertNil(client.oidcConfig)

        let config = try await client.fetchOidcConfig()
        XCTAssertNotNil(config)
        XCTAssertEqual(config, client.oidcConfig)
    }

    func testFetchOidcConfigCachedOk() async throws {
        let client = buildClient()
        let mockConfig = try! JSONDecoder().decode(LogtoCore.OidcConfigResponse.self, from: Data("""
            {
                "authorizationEndpoint": "1",
                "tokenEndpoint": "2",
                "endSessionEndpoint": "3",
                "revocationEndpoint": "4",
                "userinfoEndpoint": "5",
                "jwksUri": "6",
                "issuer": "7"
            }
        """.utf8))

        client.oidcConfig = mockConfig
        let config = try await client.fetchOidcConfig()
        XCTAssertEqual(config, mockConfig)
        XCTAssertEqual(client.oidcConfig, mockConfig)
    }

    func testFetchOidcConfigFailed() async throws {
        let client = buildClient(withOidcEndpoint: "/bad")
        XCTAssertNil(client.oidcConfig)

        do {
            _ = try await client.fetchOidcConfig()
        } catch {
            XCTAssertNil(client.oidcConfig)
            return
        }

        XCTFail()
    }
}
