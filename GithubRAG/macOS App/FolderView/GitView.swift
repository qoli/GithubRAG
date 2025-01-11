//
//  GitCommitAgentView.swift
//  GithubRAG
//
//  Created by 黃佁媛 on 2025/1/11.
//

import SwiftUI

struct GitView: View {
    @State var folderURL: String
    @StateObject private var rag = RagGitGenerator()

    @State private var beforeCheck: Int = 0

    @AppStorage("username") private var username: String = ""
    @AppStorage("email") private var email: String = ""

    var body: some View {
        NavigationView {
            List {
                NavigationLink {
                    Form {
                        Section {
                            HStack {
                                Button("Generate Commit Message") {
                                    rag.generateCommitMessage()
                                }

                                Button("Copy") {
                                    let pasteboard = NSPasteboard.general
                                    pasteboard.clearContents()
                                    pasteboard.setString(rag.response, forType: .string)
                                }

                                Spacer()
                            }
                        }

                        Section {
                            TextEditor(text: $rag.response)
                                .frame(maxHeight: 300)
                            TextField("Name", text: $username)
                            TextField("Email", text: $email)
                            Button("Commit") {
                                rag.commitGit(name: username, email: email)
                            }
                        }

                        Spacer()
                    }
                    .formStyle(.columns)
                    .padding()
                    .onAppear {
                        if beforeCheck == 0 && beforeCheck != rag.checkCount {
                            rag.generateCommitMessage()
                            beforeCheck = rag.checkCount
                        }
                    }
                } label: {
                    VStack(alignment: .leading) {
                        Text("Generate Commit Message")
                        Text("Base \(rag.checkCount) selected")
                            .opacity(0.5)
                    }
                }

                ForEach(rag.documents) { doc in
                    let url = URL(filePath: doc.statusEntry.indexToWorkDir?.newFile?.path ?? "")
                    let index = rag.documents.firstIndex(where: { $0.id == doc.id })

                    NavigationLink(destination:

                        ZStack(alignment: .topLeading) {
                            ScrollView(.vertical) {
                                Text(doc.document.content)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            }
                        }
                        .padding()

                    ) {
                        VStack(alignment: .leading) {
                            Toggle(isOn: $rag.documents[index ?? 0].check) {
                                Text(url.lastPathComponent)
                            }

                            Text(url.description)
                                .font(.caption2)
                                .opacity(0.5)
                                .lineLimit(1)
                                .truncationMode(.head)
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
