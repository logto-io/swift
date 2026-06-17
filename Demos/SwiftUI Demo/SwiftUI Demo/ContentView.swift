//
//  ContentView.swift
//  SwiftUI Demo
//
//  Created by Gao Sun on 2022/1/28.
//

import Logto
import LogtoClient
import SwiftUI

// MARK: - 1) Edit these values

enum DemoAuthConfig {
    static let endpoint = "<YOUR_LOGTO_ENDPOINT>"
    static let appId = "<YOUR_APP_ID>"
    static let redirectUri = "<YOUR_REDIRECT_URI>" // e.g. "io.logto://callback"

    // MARK: Optional config items

    static let resources: [String] = [
        "<YOUR_API_RESOURCE>", // e.g. "https://api.example.com"
    ]

    static let resourceToRequestTokenFor = "<YOUR_API_RESOURCE>"
    static let organizationId = "<YOUR_ORGANIZATION_ID>"

    static let scopes: [String] = [
        UserScope.email.rawValue,
        UserScope.roles.rawValue,
        UserScope.organizations.rawValue,
        UserScope.organizationRoles.rawValue,
    ]
}

// MARK: - 2) ViewModel

@MainActor
final class DemoAuthViewModel: ObservableObject {
    @Published var isAuthenticated = false
    @Published var isSigningIn = false
    @Published var lastError: String?
    @Published var output: String = ""

    private let client: LogtoClient?
    var isConfigured: Bool { client != nil }

    init() {
        let c = Self.makeClient()
        client = c
        isAuthenticated = c?.isAuthenticated ?? false

        if c == nil {
            log("config invalid: please update DemoAuthConfig placeholders")
        } else if c?.isAuthenticated == true {
            log("already authenticated")
        }
    }

    private static func makeClient() -> LogtoClient? {
        guard let config = try? LogtoConfig(
            endpoint: DemoAuthConfig.endpoint,
            appId: DemoAuthConfig.appId,
            scopes: DemoAuthConfig.scopes,
            resources: DemoAuthConfig.resources
        ) else {
            return nil
        }
        return LogtoClient(useConfig: config)
    }

    // MARK: Actions

    func signIn() async {
        guard let client else { logNotConfigured(); return }
        guard !isSigningIn else { return }

        isSigningIn = true
        defer {
            isSigningIn = false
        }

        clearError()
        do {
            try await client.signInWithBrowser(redirectUri: DemoAuthConfig.redirectUri)
            isAuthenticated = true
            log("sign-in success")
        } catch {
            isAuthenticated = false
            handle(error, context: "sign-in")
        }
    }

    func signOut() async {
        guard let client else { logNotConfigured(); return }
        clearError()
        await client.signOut()
        isAuthenticated = false
        log("signed out")
    }

    func printIdTokenClaims() {
        guard let client else { logNotConfigured(); return }
        clearError()
        do {
            let claims = try client.getIdTokenClaims()
            log("id token claims:\n\(claims)")
        } catch {
            handle(error, context: "get id token claims")
        }
    }

    func fetchUserInfo() async {
        guard let client else { logNotConfigured(); return }
        clearError()
        do {
            let userInfo = try await client.fetchUserInfo()
            log("userinfo:\n\(userInfo)")
        } catch {
            handle(error, context: "fetch userinfo")
        }
    }

    func fetchAccessTokenClaims(for resource: String) async {
        guard let client else { logNotConfigured(); return }
        clearError()
        do {
            let claims = try await client.getAccessTokenClaims(for: resource)
            log("access token claims for \(resource):\n\(claims)")
        } catch {
            handle(error, context: "get access token claims")
        }
    }

    func fetchOrganizationTokenClaims(for organizationId: String) async {
        guard let client else { logNotConfigured(); return }
        clearError()
        do {
            let claims = try await client.getOrganizationTokenClaims(forId: organizationId)
            log("organization token claims for \(organizationId):\n\(claims)")
        } catch {
            handle(error, context: "get organization token claims")
        }
    }

    func fetchAccessTokenClaimsInOrg(resource: String, organizationId: String) async {
        guard let client else { logNotConfigured(); return }
        clearError()
        do {
            let claims = try await client.getAccessTokenClaims(for: resource, organizationId: organizationId)
            log("access token claims for \(resource) in org \(organizationId):\n\(claims)")
        } catch {
            handle(error, context: "get access token claims in org")
        }
    }

    // MARK: Helpers

    private func clearError() {
        lastError = nil
    }

    private func log(_ message: String) {
        output = message
        print(message)
    }

    private func logNotConfigured() {
        lastError = "Logto is not configured. Please update DemoAuthConfig."
        log(lastError!)
    }

    private func handle(_ error: Error, context: String) {
        var msg = "[\(context)] \(error.localizedDescription)"

        if let signInErr = error as? LogtoClientErrors.SignIn,
           let resp = signInErr.innerError as? LogtoErrors.Response,
           case let LogtoErrors.Response.withCode(_, _, data) = resp,
           let data = data
        {
            msg += "\n\nresponse:\n" + String(decoding: data, as: UTF8.self)
        }

        lastError = msg
        log(msg)
    }
}

// MARK: - 3) UI

struct ContentView: View {
    @StateObject private var vm = DemoAuthViewModel()

    var body: some View {
        NavigationView {
            Form {
                Section("Status") {
                    HStack {
                        Text("Configured")
                        Spacer()
                        Text(vm.isConfigured ? "Yes" : "No")
                            .foregroundColor(vm.isConfigured ? .green : .secondary)
                    }

                    HStack {
                        Text("Authenticated")
                        Spacer()
                        Text(vm.isAuthenticated ? "Yes" : "No")
                            .foregroundColor(vm.isAuthenticated ? .green : .secondary)
                    }

                    if let err = vm.lastError {
                        Text(err)
                            .foregroundColor(.red)
                            .font(.footnote)
                            .textSelection(.enabled)
                    }
                }

                Section("Actions") {
                    Button(vm.isSigningIn ? "Signing In..." : "Sign In") { Task { await vm.signIn() } }
                        .disabled(!vm.isConfigured || vm.isAuthenticated || vm.isSigningIn)

                    Button("Sign Out") { Task { await vm.signOut() } }
                        .disabled(!vm.isConfigured || !vm.isAuthenticated || vm.isSigningIn)

                    Button("Print ID Token Claims") { vm.printIdTokenClaims() }
                        .disabled(!vm.isConfigured || !vm.isAuthenticated)

                    Button("Fetch Userinfo") { Task { await vm.fetchUserInfo() } }
                        .disabled(!vm.isConfigured || !vm.isAuthenticated)

                    Button("Fetch access token claims") {
                        Task { await vm.fetchAccessTokenClaims(for: DemoAuthConfig.resourceToRequestTokenFor) }
                    }
                    .disabled(!vm.isConfigured || !vm.isAuthenticated)

                    Button("Fetch organization token claims") {
                        Task { await vm.fetchOrganizationTokenClaims(for: DemoAuthConfig.organizationId) }
                    }
                    .disabled(!vm.isConfigured || !vm.isAuthenticated)

                    Button("Fetch access token claims in organization") {
                        Task {
                            await vm.fetchAccessTokenClaimsInOrg(
                                resource: DemoAuthConfig.resourceToRequestTokenFor,
                                organizationId: DemoAuthConfig.organizationId
                            )
                        }
                    }
                    .disabled(!vm.isConfigured || !vm.isAuthenticated)
                }

                Section("Output") {
                    Text(vm.output.isEmpty ? "(no output)" : vm.output)
                        .font(.footnote)
                        .textSelection(.enabled)
                }
            }
            .navigationTitle("Logto SwiftUI Demo")
        }
    }
}
