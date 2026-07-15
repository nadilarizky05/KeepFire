//
//  RepositoryProtocols.swift
//  KeepFireV.2
//
//  Created by Nadila Rizky Amelia on 14/07/26.
//

import Combine
import RxSwift
import Foundation

protocol DreamRepositoryProtocol {
    var allDreamsPublisher: AnyPublisher<[Dream], Never> { get }
    var savedDreamsPublisher: AnyPublisher<[Dream], Never> { get }

    func addDream(text: String, sharedBy: String, avatarEmoji: String)
    func skipDream(_ dream: Dream)
    func keepDream(_ dream: Dream)
    func deleteSavedDream(_ dream: Dream)
}

protocol ChatRepositoryProtocol {
    var chatsObservable: Observable<[Chat]> { get }
    
    func chatObservable(for id: UUID) -> Observable<Chat?>
    func createChatIfNeeded(contactName: String, avatarEmoji: String, dreamText: String, draftTemplate: String)
    func updateDraft(chatID: UUID, text: String)
    func sendMessage(chatID: UUID)
    func deleteChat(chatID: UUID)
}
