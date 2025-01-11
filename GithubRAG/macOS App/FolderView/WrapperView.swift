//
//  FolderView.swift
//  GithubRAG
//
//  Created by 黃佁媛 on 2025/1/10.
//

import CodeEditor
import SwiftUI

struct WrapperView: View {
    @State var item: Item

    @Environment(\.managedObjectContext) private var viewContext

    var body: some View {
        NavigationLink {
            ZStack {
                if let folderURL = item.folderURL {
                    GitView(folderURL: folderURL)
                } else {
                    Text("No folder URL")
                }
            }
            .navigationTitle(item.folderName)
            .toolbar {
                ToolbarItem(placement: .automatic) {
                    Button(action: {
                        deleteItem()
                    }, label: {
                        Image(systemName: "trash")
                    })
                }
            }

        } label: {
            Label(item.folderName, systemImage: "folder")
        }
    }

    private func deleteItem() {
        viewContext.delete(item)

        do {
            try viewContext.save()
        } catch {
            // Replace this implementation with code to handle the error appropriately.
            let nsError = error as NSError
            print("Unresolved error \(nsError), \(nsError.userInfo)")
        }
    }
}

// #Preview {
//    FolderView()
// }
