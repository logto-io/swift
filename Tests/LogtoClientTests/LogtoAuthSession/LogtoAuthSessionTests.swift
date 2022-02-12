import AuthenticationServices
import Logto
@testable import LogtoClient
import XCTest

struct LogtoWebAuthSessionMock: LogtoWebAuthSession {
    let url: URL
    let completionHandler: (URL?, Error?) -> Void

    init(url: URL, callbackURLScheme _: String?, completionHandler: @escaping (URL?, Error?) -> Void) {
        self.url = url
        self.completionHandler = completionHandler
    }

    func start() -> Bool {
        guard url.path != "/canceled" else {
            completionHandler(nil, ASWebAuthenticationSessionError(.canceledLogin))
            return true
        }

        completionHandler(nil, nil)

        return true
    }
}

final class LogtoAuthSessionTests: XCTestCase {
    func getMockOidcConfig(authorizationEndpoint: String = "https://logto.dev/canceled") -> LogtoCore
        .OidcConfigResponse
    {
        try! JSONDecoder().decode(LogtoCore.OidcConfigResponse.self, from: Data("""
            {
                "authorizationEndpoint": "\(authorizationEndpoint)",
                "tokenEndpoint": "",
                "endSessionEndpoint": "",
                "revocationEndpoint": "",
                "userinfoEndpoint": "",
                "jwksUri": "",
                "issuer": ""
            }
        """.utf8))
    }

    func testAuthSessionCanceled() {
        let expectFailure = expectation(description: "Auth session failure")
        let session = LogtoAuthSession(
            logtoConfig: try! LogtoConfig(endpoint: "https://logto.dev", clientId: ""),
            oidcConfig: getMockOidcConfig(),
            redirectUri: URL(string: "https://logto.dev")!
        ) {
            guard case let .failure(error: error) = $0, error.type == .authFailed,
                  let innerError = error.innerError as? ASWebAuthenticationSessionError,
                  innerError.code == .canceledLogin
            else {
                XCTFail()
                return
            }

            expectFailure.fulfill()
        }

        session.start(withSessionType: LogtoWebAuthSessionMock.self)
        wait(for: [expectFailure], timeout: 1)
    }
}
