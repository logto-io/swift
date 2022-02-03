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
    @State var isAuthenticated = false
    @State var authError: Error?

    let client: LogtoClient?

    init() {
        guard let config = try? LogtoConfig(
            endpoint: "https://logto.dev",
            clientId: "z4skkM1Z8LLVSl1JCmVZO",
            resources: ["https://api.logto.io"]
        ) else {
            client = nil
            return
        }
        client = LogtoClient(useConfig: config)
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
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
