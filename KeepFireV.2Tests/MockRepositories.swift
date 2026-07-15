//
//  MockRepositories.swift
//  KeepFireV.2
//
//  Created by Nadila Rizky Amelia on 14/07/26.
//

import Combine
import RxSwift
import RxRelay
import Foundation
@testable import KeepFireV_2

final class MockDreamRepository: DreamRepositoryProtocol {
    let allSubject = CurrentValueSubject<[Dream], Never>([])
    let savedSubject = CurrentValueSubject<[Dream], Never>([])

    private(set) var addedDreams: [(text: String, sharedBy: String, avatarEmoji: String)] = []
    private(set) var skippedDreams: [Dream] = []
    private(set) var keptDreams: [Dream] = []
    private(set) var deletedSavedDreams: [Dream] = []

    var allDreamsPublisher: AnyPublisher<[Dream], Never> { allSubject.eraseToAnyPublisher() }
    var savedDreamsPublisher: AnyPublisher<[Dream], Never> { savedSubject.eraseToAnyPublisher() }

    func addDream(text: String, sharedBy: String, avatarEmoji: String) {
        addedDreams.append((text, sharedBy, avatarEmoji))
    }

    func skipDream(_ dream: Dream) {
        skippedDreams.append(dream)
        allSubject.value.removeAll { $0.id == dream.id }
    }

    func keepDream(_ dream: Dream) {
        keptDreams.append(dream)
        allSubject.value.removeAll { $0.id == dream.id }
        var saved = dream
        saved.isSaved = true
        savedSubject.value.append(saved)
    }

    func deleteSavedDream(_ dream: Dream) {
        deletedSavedDreams.append(dream)
        savedSubject.value.removeAll { $0.id == dream.id }
    }
}

final class MockChatRepository: ChatRepositoryProtocol {
    let chatsRelay = BehaviorRelay<[Chat]>(value: [])
    private(set) var createChatCallCount = 0
    private(set) var lastDraftUpdate: (chatID: UUID, text: String)?
    private(set) var sentMessageChatIDs: [UUID] = []
    private(set) var deletedChatIDs: [UUID] = []

    var chatsObservable: Observable<[Chat]> { chatsRelay.asObservable() }

    func chatObservable(for id: UUID) -> Observable<Chat?> {
        chatsObservable.map { $0.first(where: { $0.id == id }) }
    }

    func createChatIfNeeded(contactName: String, avatarEmoji: String, dreamText: String, draftTemplate: String) {
        createChatCallCount += 1
        let exists = chatsRelay.value.contains { $0.contactName == contactName && $0.dreamText == dreamText }
        guard !exists else { return }
        let chat = Chat(contactName: contactName, avatarEmoji: avatarEmoji, dreamText: dreamText, draftText: draftTemplate)
        chatsRelay.accept(chatsRelay.value + [chat])
    }

    func updateDraft(chatID: UUID, text: String) {
        lastDraftUpdate = (chatID, text)
        var chats = chatsRelay.value
        guard let index = chats.firstIndex(where: { $0.id == chatID }) else { return }
        chats[index].draftText = text
        chatsRelay.accept(chats)
    }

    func sendMessage(chatID: UUID) {
        sentMessageChatIDs.append(chatID)
        var chats = chatsRelay.value
        guard let index = chats.firstIndex(where: { $0.id == chatID }) else { return }
        let text = chats[index].draftText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else { return }
        chats[index].messages.append(ChatMessage(text: text, isMe: true))
        chats[index].draftText = ""
        chatsRelay.accept(chats)
    }

    func deleteChat(chatID: UUID) {
        deletedChatIDs.append(chatID)
        chatsRelay.accept(chatsRelay.value.filter { $0.id != chatID })
    }
}
