//
//  ChatViewModels.swift
//  KeepFireV.2
//
//  Created by Nadila Rizky Amelia on 14/07/26.
//

import Combine
import RxSwift
import Foundation

@MainActor
final class LetMeCookViewModel: ObservableObject {
    @Published private(set) var chats: [Chat] = []
    private let repository: ChatRepositoryProtocol
    private let disposeBag = DisposeBag()

    init(repository: ChatRepositoryProtocol) {
        self.repository = repository
        repository.chatsObservable
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] in self?.chats = $0 })
            .disposed(by: disposeBag)
    }

    func delete(_ chat: Chat) { repository.deleteChat(chatID: chat.id) }
}

@MainActor
final class ChatDetailViewModel: ObservableObject {
    @Published var draftText: String = ""
    @Published private(set) var chat: Chat?

    private let chatID: UUID
    private let repository: ChatRepositoryProtocol
    private let disposeBag = DisposeBag()
    private var cancellables = Set<AnyCancellable>()
    private var didInitializeDraft = false

    init(chatID: UUID, repository: ChatRepositoryProtocol) {
        self.chatID = chatID
        self.repository = repository

        repository.chatObservable(for: chatID)
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] chat in
                guard let self else { return }
                self.chat = chat
                if let chat, !self.didInitializeDraft {
                    self.draftText = chat.draftText
                    self.didInitializeDraft = true
                }
            })
            .disposed(by: disposeBag)

        $draftText
            .dropFirst()
            .debounce(for: .milliseconds(300), scheduler: DispatchQueue.main)
            .sink { [weak self] text in
                guard let self else { return }
                self.repository.updateDraft(chatID: self.chatID, text: text)
            }
            .store(in: &cancellables)
    }

    var canSend: Bool { !draftText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }

    func send() {
        guard canSend else { return }
        repository.sendMessage(chatID: chatID)
        draftText = ""
    }
}
