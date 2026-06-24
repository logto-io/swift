import Logto
@testable import LogtoClient
import XCTest
#if os(iOS)
    import AuthenticationServices
#endif

extension LogtoClientTests {
    func testClearCredentialsOk() async {
        let client = buildClient(withToken: true)
        let error = await client.clearCredentials()

        XCTAssertNil(error)
        XCTAssertNil(client.refreshToken)
        XCTAssertNil(client.idToken)
        XCTAssertEqual(client.accessTokenMap.count, 0)
    }

    func testClearCredentialsNotAuthenticated() async {
        let client = buildClient()
        let error = await client.clearCredentials()

        XCTAssertEqual(error?.type, .notAuthenticated)
    }

    func testClearCredentialsUnableToFetchOidcConfig() async {
        let client = buildClient(withOidcEndpoint: "/bad", withToken: true)
        let error = await client.clearCredentials()

        XCTAssertEqual(error?.type, .unableToFetchOidcConfig)
    }

    func testClearCredentialsUnableToRevokeToken() async {
        let client = buildClient(withOidcEndpoint: "/oidc_config:bad", withToken: true)
        let error = await client.clearCredentials()

        XCTAssertEqual(error?.type, .unableToRevokeToken)
        XCTAssertNil(client.refreshToken)
        XCTAssertNil(client.idToken)
        XCTAssertEqual(client.accessTokenMap.count, 0)
    }

    #if os(iOS)
        @MainActor
        func testSignOutOk() async throws {
            let client = buildClient(withToken: true)
            let postLogoutRedirectUri = try XCTUnwrap(URL(string: "io.logto.test://signed-out"))
            var capturedSignOutUri: URL?
            var capturedCallback: LogtoASWebAuthenticationSession.AuthenticationCallback?
            var mockSession: SignOutSystemAuthenticationSessionMock!

            let error = await client.signOut(
                postLogoutRedirectUri: postLogoutRedirectUri.absoluteString
            ) { signOutUri, callback, completionHandler in
                capturedSignOutUri = signOutUri
                capturedCallback = callback

                mockSession = SignOutSystemAuthenticationSessionMock(
                    callbackUri: postLogoutRedirectUri,
                    completionHandler: completionHandler
                )
                return mockSession
            }

            XCTAssertNil(error)
            XCTAssertNil(client.refreshToken)
            XCTAssertNil(client.idToken)
            XCTAssertEqual(client.accessTokenMap.count, 0)
            XCTAssertEqual(capturedSignOutUri?.scheme, "https")
            XCTAssertEqual(capturedSignOutUri?.host, "logto.dev")
            XCTAssertEqual(capturedSignOutUri?.path, "/end:good")
            XCTAssertEqual(capturedCallback, .customScheme("io.logto.test"))
            XCTAssertTrue(try queryItems(in: XCTUnwrap(capturedSignOutUri)).contains(URLQueryItem(
                name: "client_id",
                value: "foo"
            )))
            XCTAssertTrue(try queryItems(in: XCTUnwrap(capturedSignOutUri)).contains(URLQueryItem(
                name: "post_logout_redirect_uri",
                value: postLogoutRedirectUri.absoluteString
            )))
            XCTAssertFalse(try queryItems(in: XCTUnwrap(capturedSignOutUri)).contains(URLQueryItem(
                name: "id_token_hint",
                value: initialIdToken
            )))
            XCTAssertFalse(mockSession.prefersEphemeralWebBrowserSession)
            XCTAssertNotNil(mockSession.presentationContextProvider)
        }

        @MainActor
        func testSignOutWithHttpsRedirectUsesHttpsCallback() async throws {
            let client = buildClient(withToken: true)
            let postLogoutRedirectUri = try XCTUnwrap(URL(string: "https://example.com/signed-out"))
            var capturedSignOutUri: URL?
            var capturedCallback: LogtoASWebAuthenticationSession.AuthenticationCallback?

            let error = await client.signOut(
                postLogoutRedirectUri: postLogoutRedirectUri.absoluteString
            ) { signOutUri, callback, completionHandler in
                capturedSignOutUri = signOutUri
                capturedCallback = callback

                return SignOutSystemAuthenticationSessionMock(
                    callbackUri: postLogoutRedirectUri,
                    completionHandler: completionHandler
                )
            }

            XCTAssertNil(error)
            XCTAssertNil(client.refreshToken)
            XCTAssertNil(client.idToken)
            XCTAssertEqual(client.accessTokenMap.count, 0)
            XCTAssertEqual(capturedCallback, .https(host: "example.com", path: "/signed-out"))
            XCTAssertNil(capturedCallback?.callbackURLScheme)
            XCTAssertTrue(try queryItems(in: XCTUnwrap(capturedSignOutUri)).contains(URLQueryItem(
                name: "post_logout_redirect_uri",
                value: postLogoutRedirectUri.absoluteString
            )))
        }

        @MainActor
        func testSignOutWithoutRedirectOk() async throws {
            let client = buildClient(withToken: true)
            var capturedSignOutUri: URL?
            var capturedCallback: LogtoASWebAuthenticationSession.AuthenticationCallback?
            var mockSession: SignOutSystemAuthenticationSessionMock!

            let error = await client.signOut { signOutUri, callback, completionHandler in
                capturedSignOutUri = signOutUri
                capturedCallback = callback
                mockSession = SignOutSystemAuthenticationSessionMock(completionHandler: completionHandler)
                return mockSession
            }

            XCTAssertNil(error)
            XCTAssertNil(client.refreshToken)
            XCTAssertNil(client.idToken)
            XCTAssertEqual(client.accessTokenMap.count, 0)
            XCTAssertEqual(capturedCallback, .unsupported)
            XCTAssertNotNil(mockSession.presentationContextProvider)

            let items = try queryItems(in: XCTUnwrap(capturedSignOutUri))
            XCTAssertTrue(items.contains(URLQueryItem(name: "client_id", value: "foo")))
            XCTAssertFalse(items.contains { $0.name == "post_logout_redirect_uri" })
        }

        @MainActor
        func testSignOutNotAuthenticated() async {
            let client = buildClient()
            var didCreateSession = false

            let error = await client.signOut { _, _, completionHandler in
                didCreateSession = true
                return SignOutSystemAuthenticationSessionMock(completionHandler: completionHandler)
            }

            XCTAssertEqual(error?.type, .notAuthenticated)
            XCTAssertFalse(didCreateSession)
        }

        @MainActor
        func testSignOutInvalidRedirectUri() async {
            let networkSession = SignOutNetworkSessionSpy()
            let client = buildClient(withToken: true, session: networkSession)
            var didCreateSession = false

            let error = await client.signOut(postLogoutRedirectUri: "io.logto.test://signed-out#invalid") {
                _, _, completionHandler in
                didCreateSession = true
                return SignOutSystemAuthenticationSessionMock(completionHandler: completionHandler)
            }

            XCTAssertEqual(error?.type, .invalidRedirectUri)
            XCTAssertFalse(didCreateSession)
            XCTAssertEqual(networkSession.requestCount, 0)
            // Credentials must stay intact so the caller can retry a complete sign-out with a valid URI.
            XCTAssertEqual(client.refreshToken, initialRefreshToken)
            XCTAssertEqual(client.idToken, initialIdToken)
            XCTAssertEqual(client.accessTokenMap.count, 1)
        }

        @MainActor
        func testSignOutUnableToFetchOidcConfig() async {
            let client = buildClient(withOidcEndpoint: "/bad", withToken: true)
            var didCreateSession = false

            let error = await client
                .signOut(postLogoutRedirectUri: "io.logto.test://signed-out") { _, _, completionHandler in
                    didCreateSession = true
                    return SignOutSystemAuthenticationSessionMock(completionHandler: completionHandler)
                }

            XCTAssertEqual(error?.type, .unableToFetchOidcConfig)
            XCTAssertFalse(didCreateSession)
            XCTAssertNil(client.refreshToken)
            XCTAssertNil(client.idToken)
            XCTAssertEqual(client.accessTokenMap.count, 0)
        }

        @MainActor
        func testSignOutReturnsRevokeErrorAfterBrowserSignOut() async {
            let client = buildClient(withOidcEndpoint: "/oidc_config:bad", withToken: true)

            let error = await client
                .signOut(postLogoutRedirectUri: "io.logto.test://signed-out") { _, _, completionHandler in
                    SignOutSystemAuthenticationSessionMock(
                        callbackUri: URL(string: "io.logto.test://signed-out"),
                        completionHandler: completionHandler
                    )
                }

            XCTAssertEqual(error?.type, .unableToRevokeToken)
            XCTAssertNil(client.refreshToken)
            XCTAssertNil(client.idToken)
            XCTAssertEqual(client.accessTokenMap.count, 0)
        }

        @MainActor
        func testSignOutUnexpectedCallbackUri() async {
            let client = buildClient(withToken: true)

            let error = await client
                .signOut(postLogoutRedirectUri: "io.logto.test://signed-out") { _, _, completionHandler in
                    SignOutSystemAuthenticationSessionMock(
                        callbackUri: URL(string: "io.logto.test://unexpected"),
                        completionHandler: completionHandler
                    )
                }

            XCTAssertEqual(error?.type, .unexpectedSignOutCallback)
            XCTAssertNil(client.refreshToken)
            XCTAssertNil(client.idToken)
            XCTAssertEqual(client.accessTokenMap.count, 0)
        }

        @MainActor
        func testSignOutWithoutRedirectCanceledByUserCompletesSuccessfully() async {
            let client = buildClient(withToken: true)
            let cancelError = NSError(
                domain: ASWebAuthenticationSessionError.errorDomain,
                code: ASWebAuthenticationSessionError.Code.canceledLogin.rawValue
            )

            let error = await client.signOut { _, callback, completionHandler in
                XCTAssertEqual(callback, .unsupported)
                return SignOutSystemAuthenticationSessionMock(
                    callbackError: cancelError,
                    completionHandler: completionHandler
                )
            }

            XCTAssertNil(error)
            XCTAssertNil(client.refreshToken)
            XCTAssertNil(client.idToken)
            XCTAssertEqual(client.accessTokenMap.count, 0)
        }

        @MainActor
        func testSignOutCanceledByUserCompletesSuccessfully() async {
            let client = buildClient(withToken: true)
            let cancelError = NSError(
                domain: ASWebAuthenticationSessionError.errorDomain,
                code: ASWebAuthenticationSessionError.Code.canceledLogin.rawValue
            )

            let error = await client
                .signOut(postLogoutRedirectUri: "io.logto.test://signed-out") { _, _, completionHandler in
                    SignOutSystemAuthenticationSessionMock(
                        callbackError: cancelError,
                        completionHandler: completionHandler
                    )
                }

            XCTAssertNil(error)
            XCTAssertNil(client.refreshToken)
            XCTAssertNil(client.idToken)
            XCTAssertEqual(client.accessTokenMap.count, 0)
        }

        @MainActor
        func testSignOutUnableToLaunchBrowserWhenSessionDoesNotStart() async {
            let client = buildClient(withToken: true)

            let error = await client
                .signOut(postLogoutRedirectUri: "io.logto.test://signed-out") { _, _, completionHandler in
                    SignOutSystemAuthenticationSessionMock(
                        shouldStart: false,
                        completesOnStart: false,
                        completionHandler: completionHandler
                    )
                }

            XCTAssertEqual(error?.type, .unableToLaunchBrowser)
            XCTAssertNil(client.refreshToken)
            XCTAssertNil(client.idToken)
            XCTAssertEqual(client.accessTokenMap.count, 0)
        }

        private func queryItems(in url: URL) -> [URLQueryItem] {
            URLComponents(url: url, resolvingAgainstBaseURL: true)?.queryItems ?? []
        }
    #endif
}

#if os(iOS)
    private final class SignOutSystemAuthenticationSessionMock: LogtoSystemAuthenticationSession {
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

    private struct SignOutNetworkSessionSpyError: Error {}

    private final class SignOutNetworkSessionSpy: NetworkSession {
        private(set) var requestCount = 0

        func loadData(with _: URLRequest) async -> (Data?, Error?) {
            requestCount += 1
            return (nil, SignOutNetworkSessionSpyError())
        }
    }
#endif
