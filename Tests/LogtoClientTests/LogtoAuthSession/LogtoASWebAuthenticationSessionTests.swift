#if os(iOS)
    import AuthenticationServices
    import Logto
    @testable import LogtoClient
    import LogtoMock
    import XCTest

    private let customRedirectUri = URL(string: "io.logto.test://callback")!

    private struct AuthenticationSessionMockError: Error {}

    private final class PresentationContextProviderMock: NSObject, ASWebAuthenticationPresentationContextProviding {
        func presentationAnchor(for _: ASWebAuthenticationSession) -> ASPresentationAnchor {
            ASPresentationAnchor()
        }
    }

    private final class LogtoSystemAuthenticationSessionMock: LogtoSystemAuthenticationSession {
        var presentationContextProvider: ASWebAuthenticationPresentationContextProviding?
        var prefersEphemeralWebBrowserSession = false

        private let shouldStart: Bool
        private let callbackUri: URL?
        private let callbackError: Error?
        private let completesOnStart: Bool
        private let completionHandler: LogtoASWebAuthenticationSession.CompletionHandler

        init(
            shouldStart: Bool = true,
            callbackUri: URL? = nil,
            callbackError: Error? = nil,
            completesOnStart: Bool = true,
            completionHandler: @escaping LogtoASWebAuthenticationSession.CompletionHandler
        ) {
            self.shouldStart = shouldStart
            self.callbackUri = callbackUri
            self.callbackError = callbackError
            self.completesOnStart = completesOnStart
            self.completionHandler = completionHandler
        }

        func start() -> Bool {
            if completesOnStart {
                completionHandler(callbackUri, callbackError)
            }

            return shouldStart
        }

        func cancel() {}
    }

    final class LogtoASWebAuthenticationSessionTests: XCTestCase {
        func getMockOidcConfig(
            authorizationEndpoint: String = "https://logto.dev/auth",
            tokenEndpoint: String = "https://logto.dev/token:good"
        ) -> LogtoCore
            .OidcConfigResponse
        {
            try! JSONDecoder().decode(LogtoCore.OidcConfigResponse.self, from: Data("""
                {
                    "authorizationEndpoint": "\(authorizationEndpoint)",
                    "tokenEndpoint": "\(tokenEndpoint)",
                    "endSessionEndpoint": "",
                    "revocationEndpoint": "",
                    "userinfoEndpoint": "",
                    "jwksUri": "",
                    "issuer": ""
                }
            """.utf8))
        }

        func getCallbackUri(redirectUri: URL = customRedirectUri, state: String) -> URL {
            var components = URLComponents(url: redirectUri, resolvingAgainstBaseURL: true)!
            components.queryItems = [
                URLQueryItem(name: "state", value: state),
                URLQueryItem(name: "code", value: "abc"),
            ]

            return components.url!
        }

        @MainActor
        func testStartOk() async throws {
            NetworkSessionMock.shared.tokenRequestCount = 0

            let contextProvider = PresentationContextProviderMock()
            var capturedCallbackURLScheme: String?
            var mockSession: LogtoSystemAuthenticationSessionMock!
            var authSession: LogtoASWebAuthenticationSession!

            authSession = try LogtoASWebAuthenticationSession(
                useSession: NetworkSessionMock.shared,
                logtoConfig: LogtoConfig(
                    endpoint: "https://logto.dev",
                    appId: "foo",
                    prefersEphemeralWebBrowserSession: true
                ),
                oidcConfig: getMockOidcConfig(),
                redirectUri: customRedirectUri,
                presentationContextProvider: contextProvider
            ) { authUri, callbackURLScheme, completionHandler in
                capturedCallbackURLScheme = callbackURLScheme
                XCTAssertEqual(authUri.scheme, "https")
                XCTAssertEqual(authUri.host, "logto.dev")

                mockSession = LogtoSystemAuthenticationSessionMock(
                    callbackUri: self.getCallbackUri(state: authSession.state),
                    completionHandler: completionHandler
                )
                return mockSession
            }

            let response = try await authSession.start()

            XCTAssertEqual(response.accessToken, "123")
            XCTAssertEqual(capturedCallbackURLScheme, "io.logto.test")
            XCTAssertTrue(mockSession.prefersEphemeralWebBrowserSession)
            XCTAssertNotNil(mockSession.presentationContextProvider)
        }

        func testStartAuthFailedWhenUserCancels() async throws {
            let authSession = try LogtoASWebAuthenticationSession(
                useSession: NetworkSessionMock.shared,
                logtoConfig: LogtoConfig(endpoint: "https://logto.dev", appId: "foo"),
                oidcConfig: getMockOidcConfig(),
                redirectUri: customRedirectUri
            ) { _, _, completionHandler in
                LogtoSystemAuthenticationSessionMock(
                    callbackUri: nil,
                    callbackError: AuthenticationSessionMockError(),
                    completionHandler: completionHandler
                )
            }

            do {
                _ = try await authSession.start()
            } catch let error as LogtoClientErrors.SignIn {
                XCTAssertEqual(error.type, .authFailed)
                XCTAssertNotNil(error.innerError)
                return
            }

            XCTFail()
        }

        func testStartAuthFailedWhenSessionDoesNotStart() async throws {
            let authSession = try LogtoASWebAuthenticationSession(
                useSession: NetworkSessionMock.shared,
                logtoConfig: LogtoConfig(endpoint: "https://logto.dev", appId: "foo"),
                oidcConfig: getMockOidcConfig(),
                redirectUri: customRedirectUri
            ) { _, _, completionHandler in
                LogtoSystemAuthenticationSessionMock(
                    shouldStart: false,
                    completesOnStart: false,
                    completionHandler: completionHandler
                )
            }

            do {
                _ = try await authSession.start()
            } catch let error as LogtoClientErrors.SignIn {
                XCTAssertEqual(error.type, .authFailed)
                return
            }

            XCTFail()
        }

        func testStartUnexpectedCallback() async throws {
            let authSession = try LogtoASWebAuthenticationSession(
                useSession: NetworkSessionMock.shared,
                logtoConfig: LogtoConfig(endpoint: "https://logto.dev", appId: "foo"),
                oidcConfig: getMockOidcConfig(),
                redirectUri: customRedirectUri
            ) { _, _, completionHandler in
                LogtoSystemAuthenticationSessionMock(
                    callbackUri: URL(string: "io.logto.test://callback?state=unexpected&code=abc"),
                    completionHandler: completionHandler
                )
            }

            do {
                _ = try await authSession.start()
            } catch let error as LogtoClientErrors.SignIn {
                XCTAssertEqual(error.type, .unexpectedSignInCallback)
                return
            }

            XCTFail()
        }

        func testUniversalLinkRedirectDoesNotUseCallbackURLScheme() async throws {
            let redirectUri = try XCTUnwrap(URL(string: "https://example.com/callback"))
            var capturedCallbackURLScheme: String?

            let authSession = try LogtoASWebAuthenticationSession(
                useSession: NetworkSessionMock.shared,
                logtoConfig: LogtoConfig(endpoint: "https://logto.dev", appId: "foo"),
                oidcConfig: getMockOidcConfig(),
                redirectUri: redirectUri
            ) { _, callbackURLScheme, completionHandler in
                capturedCallbackURLScheme = callbackURLScheme
                return LogtoSystemAuthenticationSessionMock(
                    shouldStart: false,
                    completesOnStart: false,
                    completionHandler: completionHandler
                )
            }

            do {
                _ = try await authSession.start()
            } catch let error as LogtoClientErrors.SignIn {
                XCTAssertEqual(error.type, .authFailed)
                XCTAssertNil(capturedCallbackURLScheme)
                return
            }

            XCTFail()
        }
    }
#endif
