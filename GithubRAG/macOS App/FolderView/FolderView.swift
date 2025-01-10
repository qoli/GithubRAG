//
//  FolderView.swift
//  GithubRAG
//
//  Created by 黃佁媛 on 2025/1/10.
//

import SwiftUI

struct FolderView: View {
    @State var item: Item
    @State var ragReply: String = ""

    @Environment(\.managedObjectContext) private var viewContext

    var body: some View {
        NavigationLink {
            ZStack(alignment: .topLeading) {
                Color.clear

                VStack(alignment: .leading) {
                    if item.folderURL != nil {
                        HStack {
                            Button("Call RAG") {
                                callRAG()
                            }
                        }

                        if ragReply != "" {
                            HStack {
                                Text(ragReply)

                                Button(action: {
                                    let pasteboard = NSPasteboard.general
                                    pasteboard.clearContents()
                                    pasteboard.setString(ragReply, forType: .string)
                                }) {
                                    Image(systemName: "doc.on.doc")
                                        .foregroundColor(.blue)
                                }
                                .buttonStyle(.plain)
                                .help("Copy to clipboard")
                            }
                        } else {
                            Text("...")
                        }
                    }
                }
                .padding()
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

    func callRAG() {
        guard let folderURL = item.folderURL else { return }
        let rag = RAGHelper(workingDirectory: folderURL)
        ragReply = rag.callGPT()
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
