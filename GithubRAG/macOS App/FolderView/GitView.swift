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
    @StateObject private var rag = RAGHelper()

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
                        if rag.response.isEmpty {
                            rag.query()
                        }
                    }
                } label: {
                    VStack(alignment: .leading) {
                        Text("Query")
                        Text("Base " + rag.documents.filter({ $0.check }).count.description + " selected")
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
                                    .lineLimit(2)
                                    .truncationMode(.head)
                            }
                        }
                        .padding(.vertical, 8)
                    }
                }
            }
            .toolbar {
                ToolbarItem(placement: .automatic) {
                    Button("reset") {
                        reset()
                    }
                }
                ToolbarItem(placement: .automatic) {
                    Button("diff") {
                        rag.diff()
                    }
                }
                ToolbarItem(placement: .automatic) {
                    Button("query") {
                        rag.query()
                    }
                }
                ToolbarItem(placement: .automatic) {
                    Button("test") {
                        rag.test()
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
                rag.diff()
            }
        }

//        VStack(alignment: .leading) {
//            if folderURL != nil {
//                HStack {
//                    Button("reset") {
//                        reset()
//                    }
//
//                    Button("diff") {
//                        rag.diff()
//                    }
//
//                    Button("query") {
//                        rag.query()
//                    }
//
//                    Button("test") {
//                        rag.test()
//                    }
//
//                    Button("Select All") {
//                        rag.documents = rag.documents.map { doc in
//                            var modifiedDoc = doc
//                            modifiedDoc.check = true
//                            return modifiedDoc
//                        }
//                    }
//
//                    Button("unSelect All") {
//                        rag.documents = rag.documents.map { doc in
//                            var modifiedDoc = doc
//                            modifiedDoc.check = false
//                            return modifiedDoc
//                        }
//                    }
//
//                    Spacer()
//
//                    Text(rag.documents.filter({ $0.check }).count.description)
//                }
//
//        HStack {
//            TextEditor(text: $rag.response)
//        }
//
//                HStack {
//                    List(rag.documents) { doc in
//                        let url = URL(filePath: doc.statusEntry.indexToWorkDir?.newFile?.path ?? "")
//
//                        if let index = rag.documents.firstIndex(where: { $0.id == doc.id }) {
//                            Toggle(isOn: $rag.documents[index].check) {
//                                Text(url.lastPathComponent)
//                            }
//
//                            ListButton(text: url.absoluteString) {
//                                someCode = doc.document.content
//                            }
//                        }
//                    }
//
//                    CodeEditor(source: $someCode, language: .swift, theme: .atelierSavannaDark)
//                }
//            }
//        }
//        .padding()
    }

    func reset() {
        rag.reset(workingDirectory: folderURL)
    }
}
