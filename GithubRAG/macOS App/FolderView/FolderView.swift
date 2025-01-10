//
//  FolderView.swift
//  GithubRAG
//
//  Created by 黃佁媛 on 2025/1/10.
//

import CodeEditor
import SwiftUI

struct FolderView: View {
    @State var item: Item

    @StateObject private var rag = RAGHelper()
    @Environment(\.managedObjectContext) private var viewContext

    @State var someCode: String = ""

    var body: some View {
        NavigationLink {
            ZStack(alignment: .topLeading) {
                Color.clear

                VStack(alignment: .leading) {
                    if item.folderURL != nil {
                        HStack {
                            Button("reset") {
                                reset()
                            }

                            Button("diff") {
                                rag.diff()
                            }

                            Button("query") {
                                rag.query()
                            }

                            Button("test") {
                                rag.test()
                            }

                            Button("Select All") {
                                rag.documents = rag.documents.map { doc in
                                    var modifiedDoc = doc
                                    modifiedDoc.check = true
                                    return modifiedDoc
                                }
                            }

                            Button("unSelect All") {
                                rag.documents = rag.documents.map { doc in
                                    var modifiedDoc = doc
                                    modifiedDoc.check = false
                                    return modifiedDoc
                                }
                            }

                            Spacer()

                            Text(rag.documents.filter({ $0.check }).count.description)
                        }

                        HStack {
                            CopyTextView(copyableText: $rag.response)
                        }

                        HStack {
                            List(rag.documents) { doc in
                                let url = URL(filePath: doc.statusEntry.indexToWorkDir?.newFile?.path ?? "")

                                if let index = rag.documents.firstIndex(where: { $0.id == doc.id }) {
                                    Toggle(isOn: $rag.documents[index].check) {
                                        Text(url.lastPathComponent)
                                    }

                                    ListButton(text: url.absoluteString) {
                                        someCode = doc.document.content
                                    }
                                }
                            }

                            CodeEditor(source: $someCode, language: .swift, theme: .atelierSavannaDark)
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

    func reset() {
        guard let folderURL = item.folderURL else {
            print("No folder URL")
            return
        }
        rag.reset(workingDirectory: folderURL)
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
