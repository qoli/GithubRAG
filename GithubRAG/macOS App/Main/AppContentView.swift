//
//  ContentView.swift
//  GithubRAG
//
//  Created by 黃佁媛 on 2025/1/10.
//

import CoreData
import SwiftUI

struct AppContentView: View {
    @Environment(\.managedObjectContext) private var viewContext

    var body: some View {
        NavigationView {
            // Folder
            FolderListView()

            // 默認 View
            WelcomeView()
        }
    }
}

#Preview {
    AppContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
