//
//  ContentView.swift
//  CometChatClone
//
//  Created by Abhishek Bagela on 07/05/26.
//

import SwiftUI
import CometChatSDK

struct ContentView: View {
    @EnvironmentObject private var auth: AuthViewModel

    var body: some View {
        Group {
            if auth.currentUser != nil {
                ConversationsListView()
            } else {
                LoginView()
            }
        }
        .animation(.default, value: auth.currentUser?.uid)
    }
}

#Preview {
    ContentView()
        .environmentObject(AuthViewModel())
}
