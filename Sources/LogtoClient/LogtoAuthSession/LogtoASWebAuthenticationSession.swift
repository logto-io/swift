#if os(iOS)
    import AuthenticationServices
    import Foundation
    import Logto

    protocol LogtoSystemAuthenticationSession: AnyObject {
        var presentationContextProvider: ASWebAuthenticationPresentationContextProviding? { get set }
        var prefersEphemeralWebBrowserSession: Bool { get set }

        func start() -> Bool
        func cancel()
    }

    extension ASWebAuthenticationSession: LogtoSystemAuthenticationSession {}

    private final class LogtoASWebAuthenticationSessionContinuation {
        private let continuation: CheckedContinuation<LogtoCore.CodeTokenResponse, Error>
        private let lock = NSLock()
        private var isResolved = false

        init(_ continuation: CheckedContinuation<LogtoCore.CodeTokenResponse, Error>) {
            self.continuation = continuation
        }

        func resume(returning response: LogtoCore.CodeTokenResponse) {
            lock.lock()
            defer { lock.unlock() }

            guard !isResolved else {
                return
            }

            isResolved = true
            continuation.resume(returning: response)
        }

        func resume(throwing error: Error) {
            lock.lock()
            defer { lock.unlock() }

            guard !isResolved else {
                return
            }

            isResolved = true
            continuation.resume(throwing: error)
        }
    }

    class LogtoASWebAuthenticationSession: LogtoAuthSession {
        typealias CompletionHandler = (URL?, Error?) -> Void

        enum AuthenticationCallback: Equatable {
            case customScheme(String)
            case https(host: String, path: String)
            case unsupported

            var callbackURLScheme: String? {
                guard case let .customScheme(scheme) = self else {
                    return nil
                }

                return scheme
            }

            #if compiler(>=5.10)
                @available(iOS 17.4, *)
                var callback: ASWebAuthenticationSession.Callback? {
                    switch self {
                    case let .customScheme(scheme):
                        return .customScheme(scheme)
                    case let .https(host, path):
                        return .https(host: host, path: path)
                    case .unsupported:
                        return nil
                    }
                }
            #endif
        }

        typealias AuthenticationSessionFactory = (
            _ url: URL,
            _ callback: AuthenticationCallback,
            _ completionHandler: @escaping CompletionHandler
        ) -> LogtoSystemAuthenticationSession

        private let authenticationSessionFactory: AuthenticationSessionFactory
        private let presentationContextProvider: ASWebAuthenticationPresentationContextProviding
        private var authenticationSession: LogtoSystemAuthenticationSession?

        required init(
            useSession session: NetworkSession = URLSession.shared,
            logtoConfig: LogtoConfig,
            oidcConfig: LogtoCore.OidcConfigResponse,
            redirectUri: URL,
            loginHint: String? = nil,
            directSignIn: LogtoCore.DirectSignInOptions? = nil,
            extraParams: [String: String]? = nil
        ) {
            authenticationSessionFactory = Self.createAuthenticationSession
            presentationContextProvider = LogtoAuthContext()

            super.init(
                useSession: session,
                logtoConfig: logtoConfig,
                oidcConfig: oidcConfig,
                redirectUri: redirectUri,
                loginHint: loginHint,
                directSignIn: directSignIn,
                extraParams: extraParams
            )
        }

        init(
            useSession session: NetworkSession = URLSession.shared,
            logtoConfig: LogtoConfig,
            oidcConfig: LogtoCore.OidcConfigResponse,
            redirectUri: URL,
            loginHint: String? = nil,
            directSignIn: LogtoCore.DirectSignInOptions? = nil,
            extraParams: [String: String]? = nil,
            presentationContextProvider: ASWebAuthenticationPresentationContextProviding = LogtoAuthContext(),
            authenticationSessionFactory: @escaping AuthenticationSessionFactory
        ) {
            self.authenticationSessionFactory = authenticationSessionFactory
            self.presentationContextProvider = presentationContextProvider

            super.init(
                useSession: session,
                logtoConfig: logtoConfig,
                oidcConfig: oidcConfig,
                redirectUri: redirectUri,
                loginHint: loginHint,
                directSignIn: directSignIn,
                extraParams: extraParams
            )
        }

        override func start() async throws -> LogtoCore.CodeTokenResponse {
            let authUri: URL

            do {
                authUri = try generateSignInUri()
            } catch let error as LogtoErrors.UrlConstruction {
                throw Errors.SignIn(type: .unableToConstructAuthUri, innerError: error)
            } catch {
                throw Errors.SignIn(type: .unknownError, innerError: error)
            }

            return try await startAuthenticationSession(with: authUri)
        }

        static func createAuthenticationSession(
            url: URL,
            callback: AuthenticationCallback,
            completionHandler: @escaping CompletionHandler
        ) -> LogtoSystemAuthenticationSession {
            #if compiler(>=5.10)
                if #available(iOS 17.4, *), let callback = callback.callback {
                    return ASWebAuthenticationSession(
                        url: url,
                        callback: callback,
                        completionHandler: completionHandler
                    )
                }
            #endif

            return ASWebAuthenticationSession(
                url: url,
                callbackURLScheme: callback.callbackURLScheme,
                completionHandler: completionHandler
            )
        }

        static func authenticationCallback(for redirectUri: URL) -> AuthenticationCallback {
            guard let scheme = redirectUri.scheme?.lowercased() else {
                return .unsupported
            }

            switch scheme {
            case "https":
                guard let host = redirectUri.host?.lowercased() else {
                    return .unsupported
                }

                let path = redirectUri.path.isEmpty ? "/" : redirectUri.path
                return .https(host: host, path: path)
            case "http":
                return .unsupported
            default:
                return .customScheme(scheme)
            }
        }

        static func callbackURLScheme(for url: URL) -> String? {
            authenticationCallback(for: url).callbackURLScheme
        }

        private var authenticationCallback: AuthenticationCallback {
            Self.authenticationCallback(for: redirectUri)
        }

        private func startAuthenticationSession(with authUri: URL) async throws -> LogtoCore.CodeTokenResponse {
            try await withCheckedThrowingContinuation { continuation in
                let resolver = LogtoASWebAuthenticationSessionContinuation(continuation)
                let session = authenticationSessionFactory(authUri,
                                                           authenticationCallback)
                { [weak self] callbackUri, error in
                    guard let self else {
                        resolver.resume(throwing: Errors.SignIn(type: .authFailed, innerError: nil))
                        return
                    }

                    guard let callbackUri else {
                        self.authenticationSession = nil
                        resolver.resume(throwing: Errors.SignIn(type: .authFailed, innerError: error))
                        return
                    }

                    Task {
                        defer {
                            self.authenticationSession = nil
                        }

                        do {
                            let response = try await self.handle(callbackUri: callbackUri)
                            resolver.resume(returning: response)
                        } catch {
                            resolver.resume(throwing: error)
                        }
                    }
                }

                session.presentationContextProvider = presentationContextProvider
                session.prefersEphemeralWebBrowserSession = logtoConfig.prefersEphemeralWebBrowserSession
                authenticationSession = session

                DispatchQueue.main.async { [weak self] in
                    let didStart = session.start()

                    guard didStart else {
                        self?.authenticationSession = nil
                        resolver.resume(throwing: Errors.SignIn(type: .authFailed, innerError: nil))
                        return
                    }
                }
            }
        }
    }
#endif
