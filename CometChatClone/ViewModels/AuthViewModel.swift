//
//  AuthViewModel.swift
//  CometChatClone
//

import Foundation
import Combine
import CometChatSDK

@MainActor
final class AuthViewModel: ObservableObject {
    @Published var currentUser: User?
    @Published var isWorking = false
    @Published var errorMessage: String?

    func bootstrap() async {
        do {
            try await CometChatService.shared.initialize()
            currentUser = CometChatService.shared.currentLoggedInUser()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func login(uid: String) async {
        let trimmed = uid.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        isWorking = true
        errorMessage = nil
        defer { isWorking = false }
        do {
            currentUser = try await CometChatService.shared.login(uid: trimmed)
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func logout() async {
        isWorking = true
        defer { isWorking = false }
        do {
            try await CometChatService.shared.logout()
            currentUser = nil
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
