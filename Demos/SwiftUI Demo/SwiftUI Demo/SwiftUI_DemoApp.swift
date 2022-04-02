//
//  SwiftUI_DemoApp.swift
//  SwiftUI Demo
//
//  Created by Gao Sun on 2022/1/28.
//

import LogtoClient
import SwiftUI

@main
struct SwiftUI_DemoApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .onOpenURL { url in
                    LogtoClient.handle(url: url)
                }
        }
    }
}
