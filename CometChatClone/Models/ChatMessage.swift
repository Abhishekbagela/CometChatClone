//
//  ChatMessage.swift
//  CometChatClone
//

import Foundation
import CometChatSDK

/// Lightweight value type the SwiftUI layer renders.
/// Keeping this decoupled from `CometChatSDK.TextMessage` lets the UI stay
/// pure-Swift, easy to preview, and easy to test.
struct ChatMessage: Identifiable, Hashable {
    let id: Int
    let senderUID: String
    let receiverUID: String
    let text: String
    let sentAt: Date
    let isMine: Bool
}

extension ChatMessage {
    /// Maps a CometChat `TextMessage` to the local model.
    /// `currentUserUID` is needed to compute `isMine`.
    init?(textMessage: TextMessage, currentUserUID: String) {
        guard let sender = textMessage.sender?.uid else { return nil }
        self.id = textMessage.id
        self.senderUID = sender
        self.receiverUID = textMessage.receiverUid
        self.text = textMessage.text
        self.sentAt = Date(timeIntervalSince1970: TimeInterval(textMessage.sentAt))
        self.isMine = sender == currentUserUID
    }

    /// Maps any `BaseMessage` (e.g. from history) to the local model when it's a text message.
    init?(baseMessage: BaseMessage, currentUserUID: String) {
        guard let textMessage = baseMessage as? TextMessage else { return nil }
        self.init(textMessage: textMessage, currentUserUID: currentUserUID)
    }
}
