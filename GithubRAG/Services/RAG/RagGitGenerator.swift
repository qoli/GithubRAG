//
//  RAGHelper.swift
//  GithubRAG
//
//  Created by 黃佁媛 on 2025/1/10.
//

import Clibgit2
import Foundation
import NaturalLanguage
import SwiftGit2
import SwiftUI

class RagGitGenerator: ObservableObject {
    let INITIAL_PROMPT = """
       You are a git commit message generator.
       Your task is to help the user write a good commit message.

       You will receive a summary of git log as first message from the user,
       a summary of git diff as the second message from the user
       and an optional hint for the commit message as the third message of the user.

       Take the whole conversation in consideration and suggest a good commit message.
       Never say anything that is not your proposed commit message, never appologize.

       - Use imperative
       - One line only
       - Be clear and concise
       - Follow standard commit message conventions
       - Do not put message in quotes
       - Put the most important changes first
       - Focus on the intent of the change, not just the code change. WHY, not how.
       - Avoid using "refactor" or "update" as they are too vague

       Always provide only the commit message as answer.
    """

    var workingDirectory: String = ""
    func reset(workingDirectory: String) {
        print(#function, workingDirectory)
        self.workingDirectory = workingDirectory

        git_libgit2_init()
    }

    deinit {
        git_libgit2_shutdown()
    }

    @Published var response: String = ""

    var checkCount: Int {
        return documents.filter({ $0.check }).count
    }

    @Published var documents: [RagDocument] = []

    struct RagDocument: Identifiable {
        var id: UUID
        var statusEntry: StatusEntry
        var document: Document
        var check: Bool = true
    }

    func requestAccess(completionHandler: @escaping (URL?) -> Void) {
        let gitRepository = URL(fileURLWithPath: workingDirectory)

        let gotAccess = gitRepository.startAccessingSecurityScopedResource()
        if !gotAccess {
            print("Could not access repository: \(gitRepository), requestAccessToFolder ...")

            requestAccessToFolder(filePath: workingDirectory) { newURL in
                if let url = newURL {
                    completionHandler(url)
                }
            }
        } else {
            print("access granted \(gitRepository)")
            completionHandler(gitRepository)
        }
    }

    func computeGitChanges() {
        requestAccess { git in

            guard let git else { return }

            do {
                self.documents.removeAll()

                let repo = try Repository.at(git).get()
                let statusEntry = try repo.status().get()

                statusEntry.forEach { statusEntry in
                    let doc = self.buildDocument(statusEntry: statusEntry, repo: repo)

                    let new = RagDocument(
                        id: UUID(),
                        statusEntry: statusEntry,
                        document: doc
                    )

                    self.documents.append(new)
                }

            } catch {
                print(error)
            }
        }
    }

    func generateCommitMessage() {
        let ragSystem: RAGSystem = RAGSystem()

        let contents = documents.filter({ $0.check == true })

        contents.forEach { doc in
            ragSystem.addDocument(doc.document)
        }

        // Generate and save response
        let query = INITIAL_PROMPT
        let response = ragSystem.generateResponse(for: "\(query)")

        self.response = response
    }

    func test() {
        let ragSystem: RAGSystem = RAGSystem()
        let response = ragSystem.generateResponse(for: "hi")
        print("Commit: \(response)")
        self.response = response
    }
}

extension RagGitGenerator {
    func getFileDiff(statusEntry: StatusEntry, repo: Repository) -> String {
        var oldContext: [String] = []
        var newContext: [String] = []

        guard let indexToWorkDir = statusEntry.indexToWorkDir else {
            return ""
        }

        if statusEntry.status == .workTreeModified {
            if let oldFile = indexToWorkDir.oldFile {
                if let blob = try? repo.blob(oldFile.oid).get(), let thisContext = String(data: blob.data, encoding: .utf8) {
                    oldContext = thisContext.components(separatedBy: .newlines)
                }
            }
        }

        if let newFile = indexToWorkDir.newFile {
            let newFileContent = getNewFileContext(newFile: newFile, repo: repo)
            newContext = newFileContent.components(separatedBy: .newlines)
        }

        let diff = FileDiffer().compareLines(oldContext, newContext)

        return diff
    }

    func buildDocument(statusEntry: StatusEntry, repo: Repository) -> Document {
        var context: String = ""

        if statusEntry.status.contains(.indexNew) {
            if let pathB = statusEntry.indexToWorkDir?.newFile?.path {
                context += "New File: \(pathB)\n"
            }
        } else {
            if let pathA = statusEntry.indexToWorkDir?.oldFile?.path, let pathB = statusEntry.indexToWorkDir?.newFile?.path {
                context += "diff --git a/\(pathA) b/\(pathB)\n"
            }
        }

        context += "Status: \(statusEntry.status)\n"

        // Get the file paths
        if let indexToWorkDir = statusEntry.indexToWorkDir {
            context += "Flags: \(indexToWorkDir.flags)\n"

            let diff = getFileDiff(statusEntry: statusEntry, repo: repo)
            context += diff
        }

        var newContext: [String] = []

        if statusEntry.status.contains(.indexNew), let newFile = statusEntry.indexToWorkDir?.newFile {
            let newFileContent = getNewFileContext(newFile: newFile, repo: repo)
            newContext = newFileContent.components(separatedBy: .newlines)
            context += newContext.joined(separator: "\n")
        }

        return Document(id: statusEntry.id.uuidString, content: context)
    }

    // Added new function to get new file context
    private func getNewFileContext(newFile: Diff.File, repo: Repository) -> String {
        // Try to get content from repo blob first
        if let blob = try? repo.blob(newFile.oid).get(),
           let thisContext = String(data: blob.data, encoding: .utf8) {
            return thisContext
        }

        // For new files that haven't been committed yet, read directly from the filesystem
        let fileURL = URL(fileURLWithPath: workingDirectory).appendingPathComponent(newFile.path)
        // Start accessing the security-scoped resource
        let gotAccess = fileURL.startAccessingSecurityScopedResource()
        defer {
            if gotAccess {
                fileURL.stopAccessingSecurityScopedResource()
            }
        }

        do {
            return try String(contentsOf: fileURL, encoding: .utf8)
        } catch {
            print("Error reading file: \(error)")
            return "" // Set empty string if file can't be read
        }
    }

    // Rest of the extension remains the same
}
