//
//  CometChatConfig.swift
//  CometChatClone
//

import Foundation

/// Credentials for the CometChat Chat SDK.
///
/// For development, the values below are CometChat's public sample-app
/// credentials so the project can be run as soon as it is cloned. Before
/// shipping, replace `appID`, `region`, and `authKey` with values from your
/// own CometChat Dashboard (https://app.cometchat.com).
///
/// In production you should never embed an `authKey` in the binary. Instead,
/// have your backend mint short-lived Auth Tokens via the CometChat REST API
/// and pass them to `CometChat.login(UID:authToken:...)`.
enum CometChatConfig {
    static let appID: String = ""   // TODO: Add appID Here
    static let region: String = ""  // TODO: Add region Here
    static let authKey: String = "" // TODO: Add authKey Here

    /// Pre-seeded sample UIDs that exist on every fresh CometChat app (handy
    /// while wiring things up; can be removed once real users are created).
    static let sampleUIDs: [String] = [
        "cometchat-uid-1",
        "cometchat-uid-2",
        "cometchat-uid-3",
        "cometchat-uid-4",
        "cometchat-uid-5",
    ]
}
