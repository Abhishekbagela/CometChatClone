//
//  ChatViewModel.swift
//  CometChatClone
//

import Foundation
import Combine
import CometChatSDK

@MainActor
final class ChatViewModel: ObservableObject {
    @Published var messages: [ChatMessage] = []
    @Published var draft: String = ""
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    let peer: User
    private let currentUID: String
    private var subscription: AnyCancellable?
    
    init(peer: User) {
        self.peer = peer
        self.currentUID = CometChatService.shared.currentLoggedInUser()?.uid ?? ""
    }
    
    func start() async {
        subscribe()
        await loadHistory()
    }
    
    func stop() {
        subscription?.cancel()
        subscription = nil
    }
    
    private func subscribe() {
        subscription = CometChatService.shared.incomingMessages
            .receive(on: DispatchQueue.main)
            .sink { [weak self] textMessage in
                guard let self else { return }
                guard self.isMessage(forThisChat: textMessage) else { return }
                if let mapped = ChatMessage(textMessage: textMessage, currentUserUID: self.currentUID),
                   !self.messages.contains(where: { $0.id == mapped.id }) {
                    self.messages.append(mapped)
                }
            }
    }
    
    private func isMessage(forThisChat textMessage: TextMessage) -> Bool {
        let senderUID = textMessage.sender?.uid ?? ""
        let receiverUID = textMessage.receiverUid
        return (senderUID == peer.uid && receiverUID == currentUID) ||
        (senderUID == currentUID && receiverUID == peer.uid)
    }
    
    private func loadHistory() async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }
        do {
            let base = try await CometChatService.shared.fetchMessages(with: peer.uid ?? "", limit: 30)
            let mapped = base.compactMap { ChatMessage(baseMessage: $0, currentUserUID: currentUID) }
            messages = mapped.sorted { $0.sentAt < $1.sentAt }
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    func send() async {
        let text = draft.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else { return }
        draft = ""
        do {
            let sent = try await CometChatService.shared.sendText(text, to: peer.uid ?? "")
            if let mapped = ChatMessage(textMessage: sent, currentUserUID: currentUID),
               !messages.contains(where: { $0.id == mapped.id }) {
                messages.append(mapped)
            }
        } catch {
            errorMessage = error.localizedDescription
            draft = text
        }
    }
}
