//
//  RealmChatRepository.swift
//  KeepFireV.2
//
//  Created by Nadila Rizky Amelia on 14/07/26.
//

import Realm
import RealmSwift
import RxSwift
import RxRelay
import Foundation

final class MessageObject: Object {
    @Persisted(primaryKey: true) var id: UUID = UUID()
    @Persisted var text: String = ""
    @Persisted var isMe: Bool = false
    @Persisted var date: Date = Date()
}

final class ChatObject: Object {
    @Persisted(primaryKey: true) var id: UUID = UUID()
    @Persisted var contactName: String = ""
    @Persisted var avatarEmoji: String = ""
    @Persisted var dreamText: String = ""
    @Persisted var draftText: String = ""
    @Persisted var messages: List<MessageObject>
    @Persisted var createdAt: Date = Date()
}

final class RealmChatRepository: ChatRepositoryProtocol {
    private let configuration: Realm.Configuration
    private let chatsRelay = BehaviorRelay<[Chat]>(value: [])
    private var notificationToken: NotificationToken?

    init(configuration: Realm.Configuration = .defaultConfiguration) {
        self.configuration = configuration
        startObserving()
    }

    deinit {
        notificationToken?.invalidate()
    }

    var chatsObservable: Observable<[Chat]> { chatsRelay.asObservable() }

    func chatObservable(for id: UUID) -> Observable<Chat?> {
        chatsObservable
            .map { $0.first(where: { $0.id == id }) }
            .distinctUntilChanged()
    }

    func createChatIfNeeded(contactName: String, avatarEmoji: String, dreamText: String, draftTemplate: String) {
        let realm = makeRealm()
        let exists = realm.objects(ChatObject.self)
            .filter("contactName == %@ AND dreamText == %@", contactName, dreamText)
            .first != nil
        guard !exists else { return }

        let chat = ChatObject()
        chat.contactName = contactName
        chat.avatarEmoji = avatarEmoji
        chat.dreamText = dreamText
        chat.draftText = draftTemplate
        try? realm.write { realm.add(chat) }
    }

    func updateDraft(chatID: UUID, text: String) {
        let realm = makeRealm()
        guard let chat = realm.object(ofType: ChatObject.self, forPrimaryKey: chatID) else { return }
        try? realm.write { chat.draftText = text }
    }

    func sendMessage(chatID: UUID) {
        let realm = makeRealm()
        guard let chat = realm.object(ofType: ChatObject.self, forPrimaryKey: chatID) else { return }
        let text = chat.draftText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else { return }
        try? realm.write {
            let message = MessageObject()
            message.text = text
            message.isMe = true
            chat.messages.append(message)
            chat.draftText = ""
        }
    }

    func deleteChat(chatID: UUID) {
        let realm = makeRealm()
        guard let chat = realm.object(ofType: ChatObject.self, forPrimaryKey: chatID) else { return }
        try? realm.write {
            realm.delete(chat.messages)
            realm.delete(chat)
        }
    }

    private func makeRealm() -> Realm {
        try! Realm(configuration: configuration)
    }

    private func startObserving() {
        let realm = makeRealm()
        let results = realm.objects(ChatObject.self).sorted(byKeyPath: "createdAt", ascending: false)
        notificationToken = results.observe { [weak self] _ in
            self?.chatsRelay.accept(results.map(Self.map))
        }
        chatsRelay.accept(results.map(Self.map))
    }

    private nonisolated static func map(_ object: ChatObject) -> Chat {
        Chat(
            id: object.id,
            contactName: object.contactName,
            avatarEmoji: object.avatarEmoji,
            dreamText: object.dreamText,
            messages: object.messages.map { ChatMessage(id: $0.id, text: $0.text, isMe: $0.isMe, date: $0.date) },
            draftText: object.draftText
        )
    }
}
