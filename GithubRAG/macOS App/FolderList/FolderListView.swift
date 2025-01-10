//
//  FolderListView.swift
//  GithubRAG
//
//  Created by 黃佁媛 on 2025/1/10.
//

import SwiftUI

struct FolderListView: View {
    @Environment(\.managedObjectContext) private var viewContext

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Item.timestamp, ascending: true)],
        animation: .default)
    private var items: FetchedResults<Item>

    @State private var isShowingFolderPicker = false

    var body: some View {
        List {
            ForEach(items) { item in
                FolderView(item: item)
            }
            .onDelete(perform: deleteItems)
        }
        .frame(minWidth: 200)
        .toolbar {
            ToolbarItem(placement: .navigation) {
                Button(action: toggleSidebar, label: {
                    Image(systemName: "sidebar.leading")
                })
            }

            ToolbarItem(placement: .status) {
                Button(action: addItem) {
                    Label("Add Item", systemImage: "plus")
                }
            }
        }
        .fileImporter(
            isPresented: $isShowingFolderPicker,
            allowedContentTypes: [.folder],
            allowsMultipleSelection: false
        ) { result in
            switch result {
            case let .success(urls):
                if let selectedURL = urls.first {
                    saveItem(folderURL: selectedURL)
                }
            case let .failure(error):
                print("Error selecting folder: \(error.localizedDescription)")
            }
        }
    }

    private func addItem() {
        isShowingFolderPicker = true
    }

    private func saveItem(folderURL: URL) {
        withAnimation {
            print("Selected folder: \(folderURL.path)")
            let newItem = Item(context: viewContext)
            newItem.timestamp = Date()
            newItem.folderURL = folderURL.absoluteString

            do {
                try viewContext.save()
            } catch {
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }

    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            offsets.map { items[$0] }.forEach(viewContext.delete)

            do {
                try viewContext.save()
            } catch {
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }

    private func toggleSidebar() {
        NSApp.keyWindow?.firstResponder?.tryToPerform(#selector(NSSplitViewController.toggleSidebar(_:)), with: nil)
    }
}

#Preview {
    FolderListView()
}
