//
//  ContentView.swift
//  SwiftUI Demo
//
//  Created by Gao Sun on 2022/1/28.
//

import LogtoClient
import SwiftUI

struct ContentView: View {
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
        if let client = client {
            Button("Sign In") {
                client.signInWithBrowser()
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
