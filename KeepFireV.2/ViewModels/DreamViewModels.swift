//
//  DreamViewModels.swift
//  KeepFireV.2
//
//  Created by Nadila Rizky Amelia on 14/07/26.
//

import Combine
import RxSwift
import Foundation

@MainActor
final class HomeViewModel: ObservableObject {
    @Published private(set) var dreams: [Dream] = []
    private let repository: DreamRepositoryProtocol
    private var cancellables = Set<AnyCancellable>()

    init(repository: DreamRepositoryProtocol) {
        self.repository = repository
        repository.allDreamsPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in self?.dreams = $0 }
            .store(in: &cancellables)
    }

    func skip(_ dream: Dream) { repository.skipDream(dream) }
    func keep(_ dream: Dream) { repository.keepDream(dream) }
}

@MainActor
final class MyCollectionViewModel: ObservableObject {
    @Published private(set) var savedDreams: [Dream] = []
    @Published private(set) var chats: [Chat] = []

    private let dreamRepository: DreamRepositoryProtocol
    private let chatRepository: ChatRepositoryProtocol
    private var cancellables = Set<AnyCancellable>()
    private let disposeBag = DisposeBag()

    init(dreamRepository: DreamRepositoryProtocol, chatRepository: ChatRepositoryProtocol) {
        self.dreamRepository = dreamRepository
        self.chatRepository = chatRepository

        dreamRepository.savedDreamsPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in self?.savedDreams = $0 }
            .store(in: &cancellables)

        chatRepository.chatsObservable
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] in self?.chats = $0 })
            .disposed(by: disposeBag)
    }

    func chat(for dream: Dream) -> Chat? {
        chats.first { $0.contactName == dream.sharedBy && $0.dreamText == dream.text }
    }

    func hasReachedOut(_ dream: Dream) -> Bool { chat(for: dream) != nil }

    func reachOut(to dream: Dream) {
        let template = "Hi \(dream.sharedBy)! I saw your dream \"\(dream.text)\" and I'd love to talk about it 🔥"
        chatRepository.createChatIfNeeded(
            contactName: dream.sharedBy,
            avatarEmoji: dream.avatarEmoji,
            dreamText: dream.text,
            draftTemplate: template
        )
    }

    func delete(_ dream: Dream) { dreamRepository.deleteSavedDream(dream) }
}

@MainActor
final class AddFireViewModel: ObservableObject {
    @Published var dreamText: String = ""
    private let repository: DreamRepositoryProtocol

    init(repository: DreamRepositoryProtocol) {
        self.repository = repository
    }

    var canSubmit: Bool {
        !dreamText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    func submit() {
        guard canSubmit else { return }
        repository.addDream(text: dreamText, sharedBy: "You", avatarEmoji: "🔥")
        dreamText = ""
    }
}
