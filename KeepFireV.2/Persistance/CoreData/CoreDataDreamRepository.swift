//
//  CoreDataDreamRepository.swift
//  KeepFireV.2
//
//  Created by Nadila Rizky Amelia on 14/07/26.
//

import CoreData
import Combine
import Foundation

@objc(DreamMO)
final class DreamMO: NSManagedObject {
    @NSManaged var id: UUID
    @NSManaged var text: String
    @NSManaged var sharedBy: String
    @NSManaged var avatarEmoji: String
    @NSManaged var isSaved: Bool
    @NSManaged var orderIndex: Int32
}

final class CoreDataStack {
    let container: NSPersistentContainer

    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "KeepFire", managedObjectModel: Self.makeModel())
        if inMemory {
            let description = NSPersistentStoreDescription()
            description.type = NSInMemoryStoreType
            container.persistentStoreDescriptions = [description]
        }
        container.loadPersistentStores { _, error in
            if let error { fatalError("Core Data failed to load store: \(error)") }
        }
        container.viewContext.automaticallyMergesChangesFromParent = true
    }

    private static func makeModel() -> NSManagedObjectModel {
        let model = NSManagedObjectModel()
        let entity = NSEntityDescription()
        entity.name = "DreamMO"
        entity.managedObjectClassName = NSStringFromClass(DreamMO.self)

        func attribute(_ name: String, _ type: NSAttributeType) -> NSAttributeDescription {
            let attribute = NSAttributeDescription()
            attribute.name = name
            attribute.attributeType = type
            attribute.isOptional = false
            return attribute
        }

        entity.properties = [
            attribute("id", .UUIDAttributeType),
            attribute("text", .stringAttributeType),
            attribute("sharedBy", .stringAttributeType),
            attribute("avatarEmoji", .stringAttributeType),
            attribute("isSaved", .booleanAttributeType),
            attribute("orderIndex", .integer32AttributeType)
        ]
        model.entities = [entity]
        return model
    }
}

final class CoreDataDreamRepository: NSObject, DreamRepositoryProtocol {
    private let context: NSManagedObjectContext
    private let allSubject = CurrentValueSubject<[Dream], Never>([])
    private let savedSubject = CurrentValueSubject<[Dream], Never>([])
    private var frc: NSFetchedResultsController<DreamMO>!

    var allDreamsPublisher: AnyPublisher<[Dream], Never> { allSubject.eraseToAnyPublisher() }
    var savedDreamsPublisher: AnyPublisher<[Dream], Never> { savedSubject.eraseToAnyPublisher() }

    init(stack: CoreDataStack, seedIfEmpty: Bool = true) {
        self.context = stack.container.viewContext
        super.init()

        let request: NSFetchRequest<DreamMO> = NSFetchRequest(entityName: "DreamMO")
        request.sortDescriptors = [NSSortDescriptor(key: "orderIndex", ascending: true)]
        frc = NSFetchedResultsController(fetchRequest: request, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
        frc.delegate = self
        try? frc.performFetch()

        if seedIfEmpty, (frc.fetchedObjects?.isEmpty ?? true) {
            seedDefaults()
            try? frc.performFetch()
        }
        publishCurrentState()
    }

    func addDream(text: String, sharedBy: String, avatarEmoji: String) {
        let minIndex = (frc.fetchedObjects?.map(\.orderIndex).min() ?? 0) - 1
        let dream = DreamMO(context: context)
        dream.id = UUID()
        dream.text = text
        dream.sharedBy = sharedBy
        dream.avatarEmoji = avatarEmoji
        dream.isSaved = false
        dream.orderIndex = minIndex
        save()
    }

    func skipDream(_ dream: Dream) {
        guard let object = fetchObject(id: dream.id) else { return }
        context.delete(object)
        save()
    }

    func keepDream(_ dream: Dream) {
        guard let object = fetchObject(id: dream.id) else { return }
        object.isSaved = true
        save()
    }

    func deleteSavedDream(_ dream: Dream) {
        guard let object = fetchObject(id: dream.id) else { return }
        context.delete(object)
        save()
    }

    private func fetchObject(id: UUID) -> DreamMO? {
        frc.fetchedObjects?.first(where: { $0.id == id })
    }

    private func save() {
        do { try context.save() } catch { assertionFailure("Failed to save Dream context: \(error)") }
    }

    private func seedDefaults() {
        for (index, seed) in Self.seedData.enumerated() {
            let dream = DreamMO(context: context)
            dream.id = UUID()
            dream.text = seed.0
            dream.sharedBy = seed.1
            dream.avatarEmoji = seed.2
            dream.isSaved = false
            dream.orderIndex = Int32(index)
        }
        save()
    }

    private func publishCurrentState() {
        let all = (frc.fetchedObjects ?? []).map {
            Dream(
                id: $0.id,
                text: $0.text,
                sharedBy: $0.sharedBy,
                avatarEmoji: $0.avatarEmoji,
                isSaved: $0.isSaved)
        }
        allSubject.send(all.filter { !$0.isSaved })
        savedSubject.send(all.filter { $0.isSaved })
    }

    private static let seedData: [(String, String, String)] = [
        ("Become a World Class iOS Developer", "Quiet Spark", "🚀"),
        ("Win the Swift Student Challenge", "Hidden Flame", "🏆"),
        ("Get an internship at Apple Singapore", "Silent Ember", "🍎"),
        ("Work as a Software Engineer at Apple Park", "Midnight Star", "💻"),
        ("Publish an app that gets Featured on the App Store", "Unknown Dreamer", "⭐️"),
        ("Meet Tim Cook in person at WWDC", "Wandering Soul", "🎤"),
        ("Present my app at the Academy's Graduation Day", "Gentle Glow", "🎓"),
        ("Become a Tech Lead in a global startup", "Secret Voyager", "🧭"),
        ("Master SwiftUI and Combine frameworks", "Echo Mind", "📐"),
        ("Get a job at a FAANG company", "Anonymous Fox", "🏢")
    ]
}

extension CoreDataDreamRepository: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        publishCurrentState()
    }
}
