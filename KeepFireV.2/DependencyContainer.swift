//
//  DependencyContainer.swift
//  KeepFireV.2
//
//  Created by Nadila Rizky Amelia on 14/07/26.
//

import Foundation
import RealmSwift

@MainActor
final class DependencyContainer {
    let dreamRepository: DreamRepositoryProtocol
    let chatRepository: ChatRepositoryProtocol

    init(inMemory: Bool = false) {
        let coreDataStack = CoreDataStack(inMemory: inMemory)
        dreamRepository = CoreDataDreamRepository(stack: coreDataStack)

        let realmConfiguration: Realm.Configuration = inMemory
            ? Realm.Configuration(inMemoryIdentifier: UUID().uuidString)
            : .defaultConfiguration
        chatRepository = RealmChatRepository(configuration: realmConfiguration)
    }

    func makeHomeViewModel() -> HomeViewModel {
        HomeViewModel(repository: dreamRepository)
    }

    func makeMyCollectionViewModel() -> MyCollectionViewModel {
        MyCollectionViewModel(dreamRepository: dreamRepository, chatRepository: chatRepository)
    }

    func makeAddFireViewModel() -> AddFireViewModel {
        AddFireViewModel(repository: dreamRepository)
    }

    func makeLetMeCookViewModel() -> LetMeCookViewModel {
        LetMeCookViewModel(repository: chatRepository)
    }

    func makeChatDetailViewModel(chatID: UUID) -> ChatDetailViewModel {
        ChatDetailViewModel(chatID: chatID, repository: chatRepository)
    }
}
