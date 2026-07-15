//
//  Models.swift
//  KeepFireV.2
//
//  Created by Nadila Rizky Amelia on 14/07/26.
//

import Foundation

struct Dream: Identifiable, Equatable, Hashable {
    let id: UUID
    var text: String
    var sharedBy: String
    var avatarEmoji: String
    var isSaved: Bool

    init(id: UUID = UUID(), text: String, sharedBy: String, avatarEmoji: String, isSaved: Bool = false) {
        self.id = id
        self.text = text
        self.sharedBy = sharedBy
        self.avatarEmoji = avatarEmoji
        self.isSaved = isSaved
    }
}

struct ChatMessage: Identifiable, Equatable, Hashable {
    let id: UUID
    var text: String
    var isMe: Bool
    var date: Date

    init(id: UUID = UUID(), text: String, isMe: Bool, date: Date = Date()) {
        self.id = id
        self.text = text
        self.isMe = isMe
        self.date = date
    }
}

struct Chat: Identifiable, Equatable, Hashable {
    let id: UUID
    var contactName: String
    var avatarEmoji: String
    var dreamText: String
    var messages: [ChatMessage]
    var draftText: String

    init(
        id: UUID = UUID(),
        contactName: String,
        avatarEmoji: String,
        dreamText: String,
        messages: [ChatMessage] = [],
        draftText: String = ""
    ) {
        self.id = id
        self.contactName = contactName
        self.avatarEmoji = avatarEmoji
        self.dreamText = dreamText
        self.messages = messages
        self.draftText = draftText
    }
}
