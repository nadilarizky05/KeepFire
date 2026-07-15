//
//  ViewModelTests.swift
//  KeepFireV.2
//
//  Created by Nadila Rizky Amelia on 14/07/26.
//

import XCTest
import Combine
import RxRelay
@testable import KeepFireV_2

@MainActor
final class HomeViewModelTests: XCTestCase {
    func test_skip_removesDreamFromList() {
        let repo = MockDreamRepository()
        let dream = Dream(text: "Test dream", sharedBy: "Someone", avatarEmoji: "🔥")
        repo.allSubject.value = [dream]
        let sut = HomeViewModel(repository: repo)

        sut.skip(dream)

        XCTAssertEqual(repo.skippedDreams, [dream])
        XCTAssertTrue(sut.dreams.isEmpty)
    }

    func test_keep_movesDreamToSaved() {
        let repo = MockDreamRepository()
        let dream = Dream(text: "Test dream", sharedBy: "Someone", avatarEmoji: "🔥")
        repo.allSubject.value = [dream]
        let sut = HomeViewModel(repository: repo)

        sut.keep(dream)

        XCTAssertEqual(repo.keptDreams, [dream])
        XCTAssertTrue(sut.dreams.isEmpty)
    }
}

@MainActor
final class MyCollectionViewModelTests: XCTestCase {
    func test_reachOut_doesNotCreateDuplicateChat() {
        let dreamRepo = MockDreamRepository()
        let chatRepo = MockChatRepository()
        let dream = Dream(text: "Win a scholarship", sharedBy: "Maya", avatarEmoji: "💡", isSaved: true)
        dreamRepo.savedSubject.value = [dream]
        let sut = MyCollectionViewModel(dreamRepository: dreamRepo, chatRepository: chatRepo)

        sut.reachOut(to: dream)
        sut.reachOut(to: dream)

        XCTAssertEqual(chatRepo.createChatCallCount, 2, "repository was asked twice...")
        XCTAssertEqual(chatRepo.chatsRelay.value.count, 1, "...but only one chat should actually exist")
    }

    func test_hasReachedOut_reflectsExistingChat() {
        let dreamRepo = MockDreamRepository()
        let chatRepo = MockChatRepository()
        let dream = Dream(text: "Win a scholarship", sharedBy: "Maya", avatarEmoji: "💡", isSaved: true)
        dreamRepo.savedSubject.value = [dream]
        let sut = MyCollectionViewModel(dreamRepository: dreamRepo, chatRepository: chatRepo)

        XCTAssertFalse(sut.hasReachedOut(dream))
        sut.reachOut(to: dream)
        XCTAssertTrue(sut.hasReachedOut(dream))
    }
}

@MainActor
final class ChatDetailViewModelTests: XCTestCase {
    func test_send_doesNothing_whenDraftIsBlank() {
        let chatRepo = MockChatRepository()
        let chat = Chat(contactName: "Maya", avatarEmoji: "💡", dreamText: "Win a scholarship", draftText: "   ")
        chatRepo.chatsRelay.accept([chat])
        let sut = ChatDetailViewModel(chatID: chat.id, repository: chatRepo)

        sut.send()

        XCTAssertTrue(chatRepo.sentMessageChatIDs.isEmpty)
        XCTAssertFalse(sut.canSend)
    }

    func test_send_callsRepository_whenDraftHasText() {
        let chatRepo = MockChatRepository()
        let chat = Chat(contactName: "Maya", avatarEmoji: "💡", dreamText: "Win a scholarship", draftText: "Hi Maya!")
        chatRepo.chatsRelay.accept([chat])
        let sut = ChatDetailViewModel(chatID: chat.id, repository: chatRepo)

        sut.send()

        XCTAssertEqual(chatRepo.sentMessageChatIDs, [chat.id])
    }
}
