//
//  DiffStatus.swift
//  GithubRAG
//
//  Created by 黃佁媛 on 2025/1/11.
//

import SwiftGit2
import Foundation

extension Diff.Status: @retroactive CustomStringConvertible {
    public var description: String {
        var messages: [String] = []

        if contains(.current) { messages.append("Current") }
        if contains(.indexNew) { messages.append("New in Index") }
        if contains(.indexModified) { messages.append("Modified in Index") }
        if contains(.indexDeleted) { messages.append("Deleted in Index") }
        if contains(.indexRenamed) { messages.append("Renamed in Index") }
        if contains(.indexTypeChange) { messages.append("Type Changed in Index") }
        if contains(.workTreeNew) { messages.append("New in Working Tree") }
        if contains(.workTreeModified) { messages.append("Modified in Working Tree") }
        if contains(.workTreeDeleted) { messages.append("Deleted in Working Tree") }
        if contains(.workTreeTypeChange) { messages.append("Type Changed in Working Tree") }
        if contains(.workTreeRenamed) { messages.append("Renamed in Working Tree") }
        if contains(.workTreeUnreadable) { messages.append("Unreadable in Working Tree") }
        if contains(.ignored) { messages.append("Ignored") }
        if contains(.conflicted) { messages.append("Conflicted") }

        return messages.isEmpty ? "No Status" : messages.joined(separator: ", ")
    }
}

extension Diff.Flags: @retroactive CustomStringConvertible {
    public var description: String {
        var messages: [String] = []
        
        if contains(.binary) { messages.append("Binary Content") }
        if contains(.notBinary) { messages.append("Text Content") }
        if contains(.validId) { messages.append("Valid Object ID") }
        if contains(.exists) { messages.append("File Exists") }
        
        return messages.isEmpty ? "No Flags" : messages.joined(separator: ", ")
    }
}

extension Diff.Delta: @retroactive Identifiable {
    public var id: UUID {
        return UUID() // 或者使用其他的唯一識別符
    }
}

extension StatusEntry: @retroactive Identifiable {
    public var id: UUID {
        return UUID() // 或者使用其他的唯一識別符
    }
}
