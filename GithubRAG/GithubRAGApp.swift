//
//  GithubRAGApp.swift
//  GithubRAG
//
//  Created by 黃佁媛 on 2025/1/10.
//

import SwiftUI

@main
struct GithubRAGApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
