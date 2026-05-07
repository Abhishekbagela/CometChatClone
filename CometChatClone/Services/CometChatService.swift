//
//  CometChatService.swift
//  CometChatClone
//
//  Thin Swift wrapper around the CometChat Chat SDK.
//  Exposes async/await methods to the rest of the app and bridges the SDK's
//  delegate-based real-time callbacks into a Combine `PassthroughSubject`
//  the ViewModels can subscribe to.
//

import Foundation
import Combine
import CometChatSDK

enum CometChatServiceError: LocalizedError {
    case notInitialized
    case unknown(String)
    case sdk(Error)

    var errorDescription: String? {
        switch self {
        case .notInitialized: return "CometChat SDK has not been initialized."
        case .unknown(let msg): return msg
        case .sdk(let error): return (error as? CometChatException)?.errorDescription ?? error.localizedDescription
        }
    }
}

/// Singleton service wrapping the CometChat Chat SDK.
///
/// Marked `nonisolated` (and `@unchecked Sendable`) because the SDK invokes
/// our delegate methods from its own threading context and the surrounding
/// project defaults every type to `@MainActor`. Mutable state is only the
/// cached `currentUser`, and it is read/written through `MainActor`-hopping
/// publishers, so this is safe in practice.
nonisolated final class CometChatService: NSObject, @unchecked Sendable {

    static let shared = CometChatService()

    /// Stream of incoming text messages from any conversation. ViewModels
    /// subscribe and filter by the peer UID they care about.
    let incomingMessages = PassthroughSubject<TextMessage, Never>()

    private let listenerID = "app.global.message.listener"
    private var didInitialize = false

    private override init() { super.init() }

    // MARK: - Initialization

    /// Initialize the SDK. Safe to call more than once; subsequent calls are no-ops.
    func initialize() async throws {
        guard !didInitialize else { return }
        let appSettings = await AppSettings.AppSettingsBuilder()
            .subscribePresenceForAllUsers()
            .setRegion(region: CometChatConfig.region)
            .build()

        try await withCheckedThrowingContinuation { (cont: CheckedContinuation<Void, Error>) in
            CometChat.init(
                appId: CometChatConfig.appID,
                appSettings: appSettings,
                onSuccess: { _ in
                    cont.resume()
                },
                onError: { error in
                    cont.resume(throwing: CometChatServiceError.sdk(error as? Error ?? CometChatServiceError.unknown("SDK init failed")))
                }
            )
        }
        didInitialize = true
        attachMessageDelegate()
    }

    // MARK: - Auth

    /// Log in using a UID and the dev Auth Key. In production swap this for
    /// `CometChat.login(UID:authToken:...)` with a token minted by your backend.
    func login(uid: String) async throws -> User {
        try await ensureInitialized()
        return try await withCheckedThrowingContinuation { (cont: CheckedContinuation<User, Error>) in
            CometChat.login(
                UID: uid,
                authKey: CometChatConfig.authKey,
                onSuccess: { user in
                    cont.resume(returning: user)
                },
                onError: { error in
                    cont.resume(throwing: CometChatServiceError.sdk(error as? Error ?? CometChatServiceError.unknown("Login failed")))
                }
            )
        }
    }

    func logout() async throws {
        try await withCheckedThrowingContinuation { (cont: CheckedContinuation<Void, Error>) in
            CometChat.logout(
                onSuccess: { _ in cont.resume() },
                onError: { error in
                    cont.resume(throwing: CometChatServiceError.sdk(error as? Error ?? CometChatServiceError.unknown("Logout failed")))
                }
            )
        }
    }

    /// Returns the currently logged-in user, if any.
    func currentLoggedInUser() -> User? {
        CometChat.getLoggedInUser()
    }

    // MARK: - Users

    func fetchUsers(limit: Int = 30) async throws -> [User] {
        try await ensureInitialized()
        let request = UsersRequest.UsersRequestBuilder()
            .set(limit: limit)
            .build()
        return try await withCheckedThrowingContinuation { (cont: CheckedContinuation<[User], Error>) in
            request.fetchNext(
                onSuccess: { users in
                    cont.resume(returning: users)
                },
                onError: { error in
                    cont.resume(throwing: CometChatServiceError.sdk(error as? Error ?? CometChatServiceError.unknown("fetchUsers failed")))
                }
            )
        }
    }

    // MARK: - Messages

    /// Fetch the most recent `limit` messages with `peerUID`, oldest-first.
    func fetchMessages(with peerUID: String, limit: Int = 30) async throws -> [BaseMessage] {
        try await ensureInitialized()
        let request = MessagesRequest.MessageRequestBuilder()
            .set(uid: peerUID)
            .set(limit: limit)
            .build()
        return try await withCheckedThrowingContinuation { (cont: CheckedContinuation<[BaseMessage], Error>) in
            request.fetchPrevious(
                onSuccess: { messages in
                    cont.resume(returning: messages ?? [])
                },
                onError: { error in
                    cont.resume(throwing: CometChatServiceError.sdk(error as? Error ?? CometChatServiceError.unknown("fetchMessages failed")))
                }
            )
        }
    }

    @discardableResult
    func sendText(_ text: String, to peerUID: String) async throws -> TextMessage {
        try await ensureInitialized()
        let message = TextMessage(receiverUid: peerUID, text: text, receiverType: .user)
        return try await withCheckedThrowingContinuation { (cont: CheckedContinuation<TextMessage, Error>) in
            CometChat.sendTextMessage(
                message: message,
                onSuccess: { sent in
                    cont.resume(returning: sent)
                },
                onError: { error in
                    cont.resume(throwing: CometChatServiceError.sdk(error as? Error ?? CometChatServiceError.unknown("sendText failed")))
                }
            )
        }
    }

    // MARK: - Delegate plumbing

    private func attachMessageDelegate() {
        CometChat.messagedelegate = self
    }

    private func ensureInitialized() async throws {
        if !didInitialize { try await initialize() }
    }
}

// MARK: - CometChatMessageDelegate

nonisolated extension CometChatService: CometChatMessageDelegate {
    func onTextMessageReceived(textMessage: TextMessage) {
        incomingMessages.send(textMessage)
    }
}
