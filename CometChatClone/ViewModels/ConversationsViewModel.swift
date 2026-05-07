//
//  ConversationsViewModel.swift
//  CometChatClone
//

import Foundation
import Combine
import CometChatSDK

@MainActor
final class ConversationsViewModel: ObservableObject {
    @Published var users: [User] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    func load() async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }
        do {
            let fetched = try await CometChatService.shared.fetchUsers(limit: 50)
            let mineUID = CometChatService.shared.currentLoggedInUser()?.uid
            users = fetched.filter { $0.uid != mineUID }
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
