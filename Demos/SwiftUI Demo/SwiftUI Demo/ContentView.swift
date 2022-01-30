//
//  ContentView.swift
//  SwiftUI Demo
//
//  Created by Gao Sun on 2022/1/28.
//

import LogtoClient
import SwiftUI

struct ContentView: View {
    @State var isAuthenticated = false
    @State var authError: Error?
    
    let client: LogtoClient?

    init() {
        guard let config = try? LogtoConfig(endpoint: "https://logto.dev", clientId: "z4skkM1Z8LLVSl1JCmVZO") else {
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
                    case .failure(let error):
                        isAuthenticated = false
                        authError = error
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
