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

    let client: LogtoClient?

    init() {
        guard let config = try? LogtoConfig(
            endpoint: "https://logto.dev",
            clientId: "z4skkM1Z8LLVSl1JCmVZO",
            resources: ["https://api.logto.io"]
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
                client.signInWithBrowser(redirectUri: "io.logto.SwiftUI-Demo://callback") {
                    switch $0 {
                    case .success:
                        isAuthenticated = true
                        authError = nil
                    case let .failure(error):
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
            }

            Button("Sign Out") {
                client.signOut()
                isAuthenticated = false
            }

            Button("Fetch Userinfo") {
                client.fetchUserInfo { userInfo, _ in
                    if let userInfo = userInfo {
                        print(userInfo)
                    }
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
