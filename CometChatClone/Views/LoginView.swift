//
//  LoginView.swift
//  CometChatClone
//

import SwiftUI

struct LoginView: View {
    @EnvironmentObject private var auth: AuthViewModel
    @State private var uid: String = "cometchat-uid-1"

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Spacer()

                VStack(spacing: 8) {
                    Image(systemName: "bubble.left.and.bubble.right.fill")
                        .font(.system(size: 56))
                        .foregroundStyle(.tint)
                    Text("CometChatClone")
                        .font(.largeTitle.bold())
                    Text("Sign in with a CometChat UID")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                VStack(alignment: .leading, spacing: 8) {
                    Text("UID")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    TextField("e.g. cometchat-uid-1", text: $uid)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                        .textFieldStyle(.roundedBorder)
                }
                .padding(.horizontal)

                if let error = auth.errorMessage {
                    Text(error)
                        .font(.footnote)
                        .foregroundStyle(.red)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }

                Button {
                    Task { await auth.login(uid: uid) }
                } label: {
                    Group {
                        if auth.isWorking {
                            ProgressView()
                        } else {
                            Text("Log In")
                                .font(.headline)
                        }
                    }
                    .frame(maxWidth: .infinity, minHeight: 48)
                }
                .buttonStyle(.borderedProminent)
                .disabled(auth.isWorking || uid.trimmingCharacters(in: .whitespaces).isEmpty)
                .padding(.horizontal)

                VStack(spacing: 4) {
                    Text("Sample UIDs")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    HStack(spacing: 8) {
                        ForEach(CometChatConfig.sampleUIDs.prefix(3), id: \.self) { sample in
                            Button(sample.replacingOccurrences(of: "cometchat-", with: "")) {
                                uid = sample
                            }
                            .buttonStyle(.bordered)
                            .controlSize(.small)
                        }
                    }
                }

                Spacer()
            }
            .padding(.vertical)
            .navigationBarHidden(true)
        }
    }
}

#Preview {
    LoginView()
        .environmentObject(AuthViewModel())
}
