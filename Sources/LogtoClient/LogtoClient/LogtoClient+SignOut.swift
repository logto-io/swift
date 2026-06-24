//
//  LogtoClient+SignOut.swift
//
//
//  Created by Gao Sun on 2022/2/4.
//

#if os(iOS)
    import AuthenticationServices
#endif
import Foundation
import Logto

public extension LogtoClient {
    /**
     Clear all tokens in memory and Keychain. Also try to revoke the Refresh Token from the OIDC provider.

     - Returns: An error if failed to clear or revoke the token. Usually the token revocation error is safe to ignore.
     */
    @discardableResult
    func clearCredentials() async -> LogtoClientErrors.SignOut? {
        guard isAuthenticated else {
            return LogtoClientErrors.SignOut(type: .notAuthenticated, innerError: nil)
        }

        let tokenToRevoke = clearLocalCredentials()

        guard let token = tokenToRevoke else {
            return nil
        }

        let oidcConfig: LogtoCore.OidcConfigResponse

        do {
            oidcConfig = try await fetchOidcConfig()
        } catch {
            return LogtoClientErrors.SignOut(type: .unableToFetchOidcConfig, innerError: error)
        }

        do {
            try await revokeRefreshToken(token, revocationEndpoint: oidcConfig.revocationEndpoint)
            return nil
        } catch {
            return LogtoClientErrors.SignOut(type: .unableToRevokeToken, innerError: error)
        }
    }

    #if os(iOS)
        /**
         Sign out from Logto in the browser and clear all local credentials.

         The post sign-out redirect URI can use a custom scheme or an HTTPS Universal Link. Custom scheme redirects can be matched and dismissed automatically on all supported iOS versions. HTTPS redirects require Associated Domains configuration with the `webcredentials` service and iOS 17.4 or newer for ASWebAuthenticationSession to match the callback and dismiss automatically.

         - Parameter postLogoutRedirectUri: One of Post sign-out redirect URIs of this application. When omitted, the browser stays on the Logto sign-out page and the user can dismiss it manually.
         - Returns: An error if the browser sign-out or token revocation failed.
         */
        @MainActor
        @discardableResult
        func signOut(postLogoutRedirectUri: String? = nil) async -> LogtoClientErrors.SignOut? {
            await signOut(
                postLogoutRedirectUri: postLogoutRedirectUri,
                authenticationSessionFactory: LogtoASWebAuthenticationSession.createAuthenticationSession
            )
        }
    #else
        @available(
            *,
            unavailable,
            message: "Browser sign-out is currently available on iOS only. Use clearCredentials() to clear local credentials."
        )
        @discardableResult
        func signOut(postLogoutRedirectUri _: String? = nil) async -> LogtoClientErrors.SignOut? {
            fatalError("Browser sign-out is currently available on iOS only.")
        }
    #endif
}

extension LogtoClient {
    @discardableResult
    func clearLocalCredentials() -> String? {
        let tokenToRevoke = refreshToken

        accessTokenMap = [:]
        refreshToken = nil
        idToken = nil

        return tokenToRevoke
    }

    func revokeRefreshToken(_ token: String, revocationEndpoint: String) async throws {
        try await LogtoCore.revoke(
            useSession: networkSession,
            token: token,
            revocationEndpoint: revocationEndpoint,
            clientId: logtoConfig.appId
        )
    }
}

#if os(iOS)
    private struct LogtoSignOutSessionError: Error {}
    private struct LogtoUnexpectedSignOutCallbackError: Error {}

    private final class LogtoSignOutSessionContinuation {
        private let continuation: CheckedContinuation<Void, Error>
        private let lock = NSLock()
        private var isResolved = false

        init(_ continuation: CheckedContinuation<Void, Error>) {
            self.continuation = continuation
        }

        func resume() {
            lock.lock()
            defer { lock.unlock() }

            guard !isResolved else {
                return
            }

            isResolved = true
            continuation.resume()
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

    extension LogtoClient {
        @MainActor
        @discardableResult
        func signOut(
            postLogoutRedirectUri: String? = nil,
            authenticationSessionFactory: @escaping LogtoASWebAuthenticationSession.AuthenticationSessionFactory
        ) async -> LogtoClientErrors.SignOut? {
            guard isAuthenticated else {
                return LogtoClientErrors.SignOut(type: .notAuthenticated, innerError: nil)
            }

            if let postLogoutRedirectUri, !Self.isValidRedirectUri(postLogoutRedirectUri) {
                clearLocalCredentials()
                return LogtoClientErrors.SignOut(type: .invalidRedirectUri, innerError: nil)
            }

            let tokenToRevoke = clearLocalCredentials()
            var resultError: LogtoClientErrors.SignOut?

            let oidcConfig: LogtoCore.OidcConfigResponse

            do {
                oidcConfig = try await fetchOidcConfig()
            } catch {
                return LogtoClientErrors.SignOut(type: .unableToFetchOidcConfig, innerError: error)
            }

            if let refreshToken = tokenToRevoke {
                do {
                    try await revokeRefreshToken(refreshToken, revocationEndpoint: oidcConfig.revocationEndpoint)
                } catch {
                    resultError = LogtoClientErrors.SignOut(type: .unableToRevokeToken, innerError: error)
                }
            }

            do {
                let signOutUri = try LogtoCore.generateSignOutUri(
                    endSessionEndpoint: oidcConfig.endSessionEndpoint,
                    clientId: logtoConfig.appId,
                    postLogoutRedirectUri: postLogoutRedirectUri
                )

                try await startSignOutSession(
                    with: signOutUri,
                    postLogoutRedirectUri: postLogoutRedirectUri.flatMap(URL.init(string:)),
                    authenticationSessionFactory: authenticationSessionFactory
                )
            } catch let error as LogtoErrors.UrlConstruction {
                return LogtoClientErrors.SignOut(type: .unableToConstructSignOutUri, innerError: error)
            } catch let error as LogtoUnexpectedSignOutCallbackError {
                return LogtoClientErrors.SignOut(type: .unexpectedSignOutCallback, innerError: error)
            } catch {
                return LogtoClientErrors.SignOut(type: .unableToLaunchBrowser, innerError: error)
            }

            return resultError
        }

        @MainActor
        private func startSignOutSession(
            with signOutUri: URL,
            postLogoutRedirectUri: URL?,
            authenticationSessionFactory: @escaping LogtoASWebAuthenticationSession.AuthenticationSessionFactory
        ) async throws {
            try await withCheckedThrowingContinuation { continuation in
                let resolver = LogtoSignOutSessionContinuation(continuation)
                let session = authenticationSessionFactory(
                    signOutUri,
                    postLogoutRedirectUri
                        .map(LogtoASWebAuthenticationSession.authenticationCallback(for:)) ?? .unsupported
                ) { [weak self] callbackUri, error in
                    self?.signOutAuthenticationSession = nil
                    self?.signOutPresentationContextProvider = nil

                    if let error {
                        if Self.isUserCancel(error) {
                            resolver.resume()
                            return
                        }

                        resolver.resume(throwing: error)
                        return
                    }

                    guard let callbackUri else {
                        resolver.resume()
                        return
                    }

                    guard let postLogoutRedirectUri else {
                        resolver.resume()
                        return
                    }

                    guard Self.isCallbackUri(callbackUri, matching: postLogoutRedirectUri) else {
                        resolver.resume(throwing: LogtoUnexpectedSignOutCallbackError())
                        return
                    }

                    resolver.resume()
                }

                let presentationContextProvider = LogtoAuthContext()
                signOutPresentationContextProvider = presentationContextProvider
                session.presentationContextProvider = presentationContextProvider
                session.prefersEphemeralWebBrowserSession = logtoConfig.prefersEphemeralWebBrowserSession
                signOutAuthenticationSession = session

                let didStart = session.start()

                guard didStart else {
                    signOutAuthenticationSession = nil
                    signOutPresentationContextProvider = nil
                    resolver.resume(throwing: LogtoSignOutSessionError())
                    return
                }
            }
        }

        private static func isValidRedirectUri(_ uri: String) -> Bool {
            guard
                let components = URLComponents(string: uri),
                let scheme = components.scheme,
                components.fragment == nil
            else {
                return false
            }

            guard let schemeRange = uri.range(of: "\(scheme):", options: [.anchored, .caseInsensitive]) else {
                return false
            }

            return uri[schemeRange.upperBound...].hasPrefix("/")
        }

        private static func isCallbackUri(_ callbackUri: URL, matching postLogoutRedirectUri: URL) -> Bool {
            callbackUri.scheme?.lowercased() == postLogoutRedirectUri.scheme?.lowercased()
                && callbackUri.host?.lowercased() == postLogoutRedirectUri.host?.lowercased()
                && callbackUri.path == postLogoutRedirectUri.path
        }

        private static func isUserCancel(_ error: Error) -> Bool {
            let error = error as NSError
            return error.domain == ASWebAuthenticationSessionError.errorDomain
                && error.code == ASWebAuthenticationSessionError.Code.canceledLogin.rawValue
        }
    }
#endif
