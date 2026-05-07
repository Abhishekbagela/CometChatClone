//
//  MessageBubbleView.swift
//  CometChatClone
//

import SwiftUI

struct MessageBubbleView: View {
    let message: ChatMessage

    private static let timeFormatter: DateFormatter = {
        let f = DateFormatter()
        f.timeStyle = .short
        f.dateStyle = .none
        return f
    }()

    var body: some View {
        HStack {
            if message.isMine { Spacer(minLength: 40) }
            VStack(alignment: message.isMine ? .trailing : .leading, spacing: 4) {
                Text(message.text)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(
                        message.isMine
                            ? Color.accentColor
                            : Color(.secondarySystemBackground)
                    )
                    .foregroundStyle(message.isMine ? Color.white : Color.primary)
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                Text(Self.timeFormatter.string(from: message.sentAt))
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
            if !message.isMine { Spacer(minLength: 40) }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 2)
    }
}

#Preview {
    VStack {
        MessageBubbleView(
            message: ChatMessage(
                id: 1,
                senderUID: "cometchat-uid-2",
                receiverUID: "cometchat-uid-1",
                text: "Hey, how are you?",
                sentAt: Date(),
                isMine: false
            )
        )
        MessageBubbleView(
            message: ChatMessage(
                id: 2,
                senderUID: "cometchat-uid-1",
                receiverUID: "cometchat-uid-2",
                text: "Doing great, thanks for asking!",
                sentAt: Date(),
                isMine: true
            )
        )
    }
}
