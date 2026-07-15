//
//  RepositoryTests.swift
//  KeepFireV.2
//
//  Created by Nadila Rizky Amelia on 14/07/26.
//

import XCTest
import CoreData
import Combine
import RealmSwift
import RxSwift
@testable import KeepFireV_2

final class CoreDataDreamRepositoryTests: XCTestCase {
    private func makeSUT() -> CoreDataDreamRepository {
        let stack = CoreDataStack(inMemory: true)
        return CoreDataDreamRepository(stack: stack, seedIfEmpty: false)
    }

    func test_addDream_appearsInAllDreamsPublisher() {
        let sut = makeSUT()
        var received: [Dream] = []
        let cancellable = sut.allDreamsPublisher.sink { received = $0 }

        sut.addDream(text: "Learn TDD", sharedBy: "Dila", avatarEmoji: "🧪")

        XCTAssertEqual(received.map(\.text), ["Learn TDD"])
        cancellable.cancel()
    }

    func test_keepDream_movesItFromAllToSaved() {
        let sut = makeSUT()
        sut.addDream(text: "Learn TDD", sharedBy: "Dila", avatarEmoji: "🧪")

        var all: [Dream] = []
        var saved: [Dream] = []
        let c1 = sut.allDreamsPublisher.sink { all = $0 }
        let c2 = sut.savedDreamsPublisher.sink { saved = $0 }

        guard let dream = all.first else { return XCTFail("Expected a seeded dream") }
        sut.keepDream(dream)

        XCTAssertTrue(all.isEmpty)
        XCTAssertEqual(saved.map(\.text), ["Learn TDD"])
        c1.cancel(); c2.cancel()
    }
}

final class RealmChatRepositoryTests: XCTestCase {
    private func makeSUT() -> RealmChatRepository {
        RealmChatRepository(configuration: Realm.Configuration(inMemoryIdentifier: UUID().uuidString))
    }

    func test_createChatIfNeeded_doesNotDuplicate() {
        let sut = makeSUT()
        sut.createChatIfNeeded(contactName: "Maya", avatarEmoji: "💡", dreamText: "Win a scholarship", draftTemplate: "Hi!")
        sut.createChatIfNeeded(contactName: "Maya", avatarEmoji: "💡", dreamText: "Win a scholarship", draftTemplate: "Hi!")

        let disposeBag = DisposeBag()
        let expectation = expectation(description: "chats emitted")
        sut.chatsObservable.subscribe(onNext: { chats in
            XCTAssertEqual(chats.count, 1)
            expectation.fulfill()
        }).disposed(by: disposeBag)
        wait(for: [expectation], timeout: 1)
    }

    func test_sendMessage_appendsMessageAndClearsDraft() {
        let sut = makeSUT()
        sut.createChatIfNeeded(contactName: "Maya", avatarEmoji: "💡", dreamText: "Win a scholarship", draftTemplate: "Hi Maya!")

        let disposeBag = DisposeBag()
        var chatID: UUID?
        let firstEmission = expectation(description: "initial chat")
        sut.chatsObservable.subscribe(onNext: { chats in
            if chatID == nil, let chat = chats.first {
                chatID = chat.id
                firstEmission.fulfill()
            }
        }).disposed(by: disposeBag)
        wait(for: [firstEmission], timeout: 1)

        guard let id = chatID else { return XCTFail("Expected chat id") }
        sut.sendMessage(chatID: id)

        let sentExpectation = expectation(description: "message sent")
        sut.chatObservable(for: id).subscribe(onNext: { chat in
            guard let chat, chat.messages.count == 1 else { return }
            XCTAssertEqual(chat.messages.first?.text, "Hi Maya!")
            XCTAssertEqual(chat.draftText, "")
            sentExpectation.fulfill()
        }).disposed(by: disposeBag)
        wait(for: [sentExpectation], timeout: 1)
    }
}
