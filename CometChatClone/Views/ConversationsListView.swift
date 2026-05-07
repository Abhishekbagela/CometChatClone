//
//  ConversationsListView.swift
//  CometChatClone
//

import SwiftUI
import CometChatSDK

struct ConversationsListView: View {
    @EnvironmentObject private var auth: AuthViewModel
    @StateObject private var viewModel = ConversationsViewModel()

    var body: some View {
        NavigationStack {
            Group {
                if viewModel.isLoading && viewModel.users.isEmpty {
                    ProgressView("Loading users…")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if let error = viewModel.errorMessage {
                    VStack(spacing: 12) {
                        Image(systemName: "exclamationmark.triangle")
                            .font(.largeTitle)
                            .foregroundStyle(.orange)
                        Text(error)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                        Button("Retry") {
                            Task { await viewModel.load() }
                        }
                        .buttonStyle(.bordered)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    List(viewModel.users, id: \.uid) { user in
                        NavigationLink(value: UserRoute(user: user)) {
                            HStack(spacing: 12) {
                                AvatarView(name: (user.name ?? user.uid) ?? "")
                                VStack(alignment: .leading, spacing: 2) {
                                    Text((user.name ?? user.uid) ?? "")
                                        .font(.body)
                                    Text(user.uid ?? "")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                                Spacer()
                                if user.status == .online {
                                    Circle()
                                        .fill(Color.green)
                                        .frame(width: 10, height: 10)
                                }
                            }
                            .padding(.vertical, 4)
                        }
                    }
                    .refreshable { await viewModel.load() }
                }
            }
            .navigationTitle("Chats")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Logout") {
                        Task { await auth.logout() }
                    }
                }
            }
            .navigationDestination(for: UserRoute.self) { route in
                ChatView(peer: route.user)
            }
            .task { await viewModel.load() }
        }
    }
}

private struct UserRoute: Hashable {
    let user: User
    static func == (lhs: UserRoute, rhs: UserRoute) -> Bool { lhs.user.uid == rhs.user.uid }
    func hash(into hasher: inout Hasher) { hasher.combine(user.uid) }
}

private struct AvatarView: View {
    let name: String
    var initials: String {
        let parts = name.split(separator: " ")
        let chars = parts.prefix(2).compactMap { $0.first }
        return String(chars).uppercased()
    }
    var body: some View {
        Circle()
            .fill(Color.accentColor.opacity(0.2))
            .overlay(
                Text(initials.isEmpty ? "?" : initials)
                    .font(.callout.bold())
                    .foregroundStyle(.tint)
            )
            .frame(width: 40, height: 40)
    }
}

#Preview {
    ConversationsListView()
        .environmentObject(AuthViewModel())
}
