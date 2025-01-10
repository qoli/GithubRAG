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

class RAGHelper: ObservableObject {
    let ragSystem: RAGSystem = RAGSystem()

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
    func update(workingDirectory: String) {
        self.workingDirectory = workingDirectory

        guard FileManager.default.fileExists(atPath: workingDirectory) else {
            fatalError("Working directory does not exist at path: \(workingDirectory)")
        }

        git_libgit2_init()
    }

    deinit {
        git_libgit2_shutdown()
    }

    @Published var documents: [Document] = []
    @Published var response: String = "..."

    func requestAccess(completionHandler: @escaping (URL?) -> Void) {
        let gitRepository = URL(fileURLWithPath: workingDirectory)

        let gotAccess = gitRepository.startAccessingSecurityScopedResource()
        if !gotAccess {
            print("Could not access repository: \(gitRepository), requestAccessToFolder ...")

            requestAccessToFolder { newURL in
                if let url = newURL {
                    completionHandler(url)
                }
            }
        } else {
            print("access granted \(gitRepository)")
            completionHandler(gitRepository)
        }
    }

    func callGPT() {
        requestAccess { git in

            guard let git else { return }

            let result = Repository.at(git)
            switch result {
            case let .success(repo):
                let latestCommit = repo
                    .HEAD()
                    .flatMap {
                        repo.commit($0.oid)
                    }

                switch latestCommit {
                case let .success(commit):
                    print("Latest Commit: \(commit.message) by \(commit.author.name)")

                case let .failure(error):
                    print("Could not get commit: \(error)")
                }

            case let .failure(error):
                print("Could not open repository: \(error)")
            }
        }
    }

    func ragCommand(_ command: String, workingDirectory: String? = nil) -> Document? {
        let content = runCommand(command, workingDirectory: workingDirectory)

        if let output = content.1 {
            return Document(id: command, content: "\(content.0), \(output)")
        }

        return nil
    }

    func ragFile(path: String, ragSystem: RAGSystem) {
        do {
            // 读取文件内容
            let content = try String(contentsOfFile: path, encoding: .utf8)
            ragSystem.addDocument(Document(id: path, content: content))
        } catch {
            print("无法读取 README.md 文件: \(error)")
        }
    }

    func runCommand(_ command: String, workingDirectory: String? = nil) -> (String, String?) {
        let process = Process()
        process.launchPath = "/bin/zsh" // 使用 zsh 作为 shell
        process.arguments = ["-c", command] // 使用 -c 选项执行命令

        if let directory = workingDirectory {
            // Add directory check before setting working directory
            guard FileManager.default.fileExists(atPath: directory) else {
                print("Error: Working directory does not exist at path: \(directory)")
                return (command, nil)
            }
            process.currentDirectoryPath = directory // 设置工作目录
        }

        let pipe = Pipe()
        process.standardOutput = pipe
        process.standardError = pipe

        process.launch()

        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        process.waitUntilExit()

        if let output = String(data: data, encoding: .utf8) {
            return (command, output)
        }

        return (command, nil)
    }
}
