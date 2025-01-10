//
//  RAGHelper.swift
//  GithubRAG
//
//  Created by 黃佁媛 on 2025/1/10.
//

import Foundation
import NaturalLanguage

class RAGHelper {
    let ragSystem: RAGSystem
    let workingDirectory: String

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

    init(workingDirectory: String) {
        ragSystem = RAGSystem()

        var workingDirectory = workingDirectory

        if workingDirectory.starts(with: "file://") {
            workingDirectory = workingDirectory.replacingOccurrences(of: "file://", with: "")
        }

        self.workingDirectory = workingDirectory

        // Add directory existence check
        guard FileManager.default.fileExists(atPath: workingDirectory) else {
            fatalError("Working directory does not exist at path: \(workingDirectory)")
        }
    }

    func callGPT() -> String {
        if runCommand("git diff", workingDirectory: workingDirectory).1 != "" {
            ragCommand("git diff", workingDirectory: workingDirectory)
            ragCommand("git status", workingDirectory: workingDirectory)

            // Generating a response
            let query = INITIAL_PROMPT
            let response = ragSystem.generateResponse(for: query)

            return response
        } else {
            return "git diff is empty"
        }
    }

    func ragCommand(_ command: String, workingDirectory: String? = nil) {
        let content = runCommand(command, workingDirectory: workingDirectory)

        if let output = content.1 {
            ragSystem.addDocument(Document(id: command, content: "\(content.0), \(output)"))
        }
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
}

extension RAGHelper {
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
