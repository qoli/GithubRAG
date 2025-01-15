//
//  Persistence.swift
//  GithubRAG
//
//  Created by 黃佁媛 on 2025/1/10.
//

import CoreData

struct PersistenceController {
    static let shared = PersistenceController()

    let container: NSPersistentContainer

    init() {
        container = NSPersistentContainer(name: "GithubRAG")

        if let storeURL = container.persistentStoreDescriptions.first?.url {
            print("Database file path: \(storeURL.path)")
        }

        container.loadPersistentStores(completionHandler: { _, error in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        container.viewContext.automaticallyMergesChangesFromParent = true
    }
}
