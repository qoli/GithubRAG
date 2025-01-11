//
//  GitCommitAgentView.swift
//  GithubRAG
//
//  Created by 黃佁媛 on 2025/1/11.
//

import CodeEditor
import SwiftUI

struct GitView: View {
    @State var folderURL: String
    @StateObject private var rag = RagGitGenerator()

    @State private var beforeCheck: Int = 0

    var body: some View {
        NavigationView {
            List {
                NavigationLink {
                    ZStack {
                        TextEditor(text: $rag.response)
                            .padding()
                    }
                    .scrollContentBackground(.hidden)
                    .onAppear {
                        if beforeCheck == 0 && beforeCheck != rag.checkCount {
                            rag.generateCommitMessage()
                            beforeCheck = rag.checkCount
                        }
                    }
                } label: {
                    VStack(alignment: .leading) {
                        Text("Query")
                        Text("Base \(rag.checkCount) selected")
                            .opacity(0.5)
                    }
                }

                ForEach(rag.documents) { doc in
                    NavigationLink(destination: CodeEditor(source: doc.document.content, language: .swift, theme: .atelierSavannaDark)) {
                        VStack(alignment: .leading) {
                            let url = URL(filePath: doc.statusEntry.indexToWorkDir?.newFile?.path ?? "")

                            if let index = rag.documents.firstIndex(where: { $0.id == doc.id }) {
                                Toggle(isOn: $rag.documents[index].check) {
                                    Text(url.lastPathComponent)
                                }

                                Text(url.description)
                                    .font(.caption2)
                                    .opacity(0.5)
                                    .lineLimit(1)
                                    .truncationMode(.head)
                            }
                        }
                        .padding(.vertical, 8)
                    }
                }
            }
            .toolbar {
                ToolbarItem(placement: .automatic) {
                    Button("Get Git Changes") {
                        reset()
                        rag.computeGitChanges()
                    }
                }
                ToolbarItem(placement: .automatic) {
                    Button("Generate Commit Message") {
                        rag.generateCommitMessage()
                    }
                }
                ToolbarItem(placement: .automatic) {
                    Button("Select All") {
                        rag.documents = rag.documents.map { doc in
                            var modifiedDoc = doc
                            modifiedDoc.check = true
                            return modifiedDoc
                        }
                    }
                }
                ToolbarItem(placement: .automatic) {
                    Button("unSelect All") {
                        rag.documents = rag.documents.map { doc in
                            var modifiedDoc = doc
                            modifiedDoc.check = false
                            return modifiedDoc
                        }
                    }
                }
            }
            .onAppear {
                reset()
                rag.computeGitChanges()
            }
        }
    }

    func reset() {
        rag.reset(workingDirectory: folderURL)
    }
}
