//
//  CometChatCloneApp.swift
//  CometChatClone
//
//  Created by Abhishek Bagela on 07/05/26.
//

import SwiftUI

@main
struct CometChatCloneApp: App {
    @StateObject private var auth = AuthViewModel()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(auth)
                .task { await auth.bootstrap() }
        }
    }
}
