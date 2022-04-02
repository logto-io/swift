//
//  ContentView.swift
//  SwiftUI Demo
//
//  Created by Gao Sun on 2022/1/28.
//

import Logto
import LogtoClient
import LogtoSocialPluginAlipay
import SwiftUI

struct ContentView: View {
    @State var isAuthenticated: Bool
    @State var authError: Error?

    let resource = "https://api.logto.io"
    let client: LogtoClient?
    let alipayPlugin = LogtoSocialPluginAlipay()

    init() {
        guard let config = try? LogtoConfig(
            endpoint: "https://logto.dev",
            clientId: "R2iRaySQYQlcgUriZW8CZ",
            resources: [resource]
        ) else {
            client = nil
            isAuthenticated = false
            return
        }
        let logtoClient = LogtoClient(useConfig: config, socialPlugins: [LogtoSocialPluginAlipay()])
        client = logtoClient
        isAuthenticated = logtoClient.isAuthenticated

        if logtoClient.isAuthenticated {
            print("authed", logtoClient.refreshToken ?? "N/A")
        }
    }

    var body: some View {
        Text("Hello, world!")
            .padding()
        if isAuthenticated {
            Text("Signed In")
                .padding()
        }
        if let authError = authError {
            Text(authError.localizedDescription)
                .foregroundColor(.red)
                .padding()
        }

        if let client = client {
            Button("Print ID Token Claims") {
                print(try! client.getIdTokenClaims())
            }
            Button("Sign In") {
                Task { [self] in
                    do {
                        let error = try await client.signInWithBrowser(redirectUri: "io.logto.SwiftUI-Demo://callback")
                        guard let error = error else {
                            isAuthenticated = true
                            authError = nil
                            return
                        }

                        isAuthenticated = false
                        authError = error
                        print("failure", error)

                        if let error = error.innerError as? LogtoErrors.Response,
                           case let LogtoErrors.Response.withCode(
                               _,
                               _,
                               data
                           ) = error, let data = data
                        {
                            print(String(decoding: data, as: UTF8.self))
                        }

                    } catch {
                        print(error)
                    }
                }
            }

            Button("Sign Out") {
                Task {
                    try await client.signOut()
                    self.isAuthenticated = false
                }
            }

            Button("Fetch Userinfo") {
                Task {
                    do {
                        let userInfo = try await client.fetchUserInfo()
                        print(userInfo)
                    } catch let error as LogtoClient.Errors.UserInfo {
                        if let error = error.innerError as? LogtoClient.Errors.AccessToken,
                           let error = error.innerError as? LogtoErrors.Response,
                           case let LogtoErrors.Response.withCode(
                               _,
                               _,
                               data
                           ) = error, let data = data
                        {
                            print(String(decoding: data, as: UTF8.self))
                        }
                    } catch {
                        print(error)
                    }
                }
            }

            Button("Fetch access token for \(resource)") {
                Task {
                    do {
                        let token = try await client.getAccessToken(for: resource)
                        print(token)
                    } catch {
                        print(error)
                    }
                }
            }

            Button("Alipay") {
                alipayPlugin.start(LogtoSocialPluginConfiguration(
                    redirectUri: URL(string: "alipay://?app_id=some_app_id&state=foo")!,
                    callbackUri: URL(string: "https://logto.dev/callback/alipay")!,
                    completion: { url in
                        print(url)
                    },
                    errorHandler: { error in
                        print(error)
                    }
                ))
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
