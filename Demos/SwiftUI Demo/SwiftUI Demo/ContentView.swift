//
//  ContentView.swift
//  SwiftUI Demo
//
//  Created by Gao Sun on 2022/1/28.
//

import LogtoClient
import SwiftUI

struct ContentView: View {
    init() {
        guard let config = try? LogtoConfig(endpoint: "https://logto.dev", clientId: "foo") else {
            return
        }
        _ = LogtoClient(useConfig: config)
    }

    var body: some View {
        Text("Hello, world!")
            .padding()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
