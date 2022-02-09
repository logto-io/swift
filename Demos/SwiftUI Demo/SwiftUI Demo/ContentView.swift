//
//  ContentView.swift
//  SwiftUI Demo
//
//  Created by Gao Sun on 2022/1/28.
//

import Logto
import LogtoClient
import SwiftUI

struct ContentView: View {
    @State var isAuthenticated: Bool
    @State var authError: Error?

    let resource = "https://api.logto.io"
    let client: LogtoClient?

    init() {
        guard let config = try? LogtoConfig(
            endpoint: "http://localhost:3001",
            clientId: "z4skkM1Z8LLVSl1JCmVZO",
            resources: [resource]
        ) else {
            client = nil
            isAuthenticated = false
            return
        }
        let logtoClient = LogtoClient(useConfig: config)
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
                client.signInWithBrowser(redirectUri: "io.logto.SwiftUI-Demo://callback") { error in
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
                }
            }

            Button("Sign Out") {
                client.signOut()
                isAuthenticated = false
            }

            Button("Fetch Userinfo") {
                client.fetchUserInfo { userInfo, error in
                    if let error = error?.innerError as? LogtoClient.Errors.AccessToken,
                       let error = error.innerError as? LogtoErrors.Response,
                       case let LogtoErrors.Response.withCode(
                           _,
                           _,
                           data
                       ) = error, let data = data
                    {
                        print(String(decoding: data, as: UTF8.self))
                    }

                    if let userInfo = userInfo {
                        print(userInfo)
                    }
                }
            }

            Button("Fetch access token for \(resource)") {
                client.getAccessToken(for: resource) {
                    print($0 ?? "N/A", $1 ?? "N/A")
                }
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
