//
//  FileDiffer.swift
//  GithubRAG
//
//  Created by 黃佁媛 on 2025/1/12.
//

import Foundation

class FileDiffer {
    // Previous lcs method remains the same
    private func lcs(_ oldLines: [String], _ newLines: [String]) -> [[Int]] {
        let m = oldLines.count
        let n = newLines.count
        var dp = Array(repeating: Array(repeating: 0, count: n + 1), count: m + 1)

        // Return early if either array is empty
        guard m > 0 && n > 0 else {
            return dp
        }

        // Safe to use range now since we've confirmed m and n are > 0
        for i in 1 ... m {
            for j in 1 ... n {
                if oldLines[i - 1] == newLines[j - 1] {
                    dp[i][j] = dp[i - 1][j - 1] + 1
                } else {
                    dp[i][j] = max(dp[i - 1][j], dp[i][j - 1])
                }
            }
        }
        return dp
    }

    // Modified backtrack method to return DiffLine array instead of String
    private func backtrack(_ dp: [[Int]], _ oldLines: [String], _ newLines: [String], _ i: Int, _ j: Int) -> [DiffLine] {
        if i <= 0 || j <= 0 {
            return []
        }

        if oldLines[i - 1] == newLines[j - 1] {
            var result = backtrack(dp, oldLines, newLines, i - 1, j - 1)
            result.append(DiffLine(type: .same, content: oldLines[i - 1]))
            return result
        } else if dp[i][j - 1] >= dp[i - 1][j] {
            var result = backtrack(dp, oldLines, newLines, i, j - 1)
            result.append(DiffLine(type: .added, content: newLines[j - 1]))
            return result
        } else {
            var result = backtrack(dp, oldLines, newLines, i - 1, j)
            result.append(DiffLine(type: .removed, content: oldLines[i - 1]))
            return result
        }
    }

    // New DiffLine type to represent each line in the diff
    private struct DiffLine {
        enum LineType {
            case same
            case added
            case removed
        }
        
        let type: LineType
        let content: String
        
        func toString() -> String {
            switch type {
            case .same: return "  \(content)"
            case .added: return "+ \(content)"
            case .removed: return "- \(content)"
            }
        }
    }

    // New method to process diff lines with context
    private func processDiffWithContext(_ diffLines: [DiffLine], contextLines: Int = 3) -> String {
        var result = ""
        var currentBlock: [DiffLine] = []
        var lastPrintedIndex = -1
        
        for i in 0..<diffLines.count {
            let line = diffLines[i]
            
            if line.type != .same {
                // Calculate the start and end indices for context
                let startIdx = max(0, i - contextLines)
                let endIdx = min(diffLines.count - 1, i + contextLines)
                
                // If this is a new block (not continuous with the previous one)
                if startIdx > lastPrintedIndex + 1 {
                    // Print the current block if it's not empty
                    if !currentBlock.isEmpty {
                        result += currentBlock.map { $0.toString() }.joined(separator: "\n") + "\n"
                        if endIdx < diffLines.count - 1 {
                            result += "...\n"
                        }
                    }
                    currentBlock = []
                }
                
                // Add context lines and the changed line
                if startIdx > lastPrintedIndex + 1 {
                    // Add preceding context
                    for j in startIdx..<i {
                        currentBlock.append(diffLines[j])
                    }
                }
                currentBlock.append(line)
                lastPrintedIndex = i
            } else if lastPrintedIndex >= 0 && i <= lastPrintedIndex + contextLines {
                // Add following context lines
                currentBlock.append(line)
                lastPrintedIndex = i
            }
        }
        
        // Print the last block
        if !currentBlock.isEmpty {
            result += currentBlock.map { $0.toString() }.joined(separator: "\n")
        }
        
        return result
    }

    // Previous readFile method remains the same
    func readFile(from path: String) -> [String] {
        do {
            let data = try Data(contentsOf: URL(fileURLWithPath: path))
            guard let content = String(data: data, encoding: .utf8) else {
                return []
            }

            var lines: [String] = []
            var currentLine = ""

            for char in content {
                if char == "\n" {
                    lines.append(currentLine)
                    currentLine = ""
                } else {
                    currentLine.append(char)
                }
            }

            if !currentLine.isEmpty {
                lines.append(currentLine)
            }

            return lines
        } catch {
            print("Error reading file: \(error)")
            return []
        }
    }

    // Modified compareLines method to use the new diff processing
    func compareLines(_ oldLines: [String], _ newLines: [String]) -> String {
        let dp = lcs(oldLines, newLines)
        let diffLines = backtrack(dp, oldLines, newLines, oldLines.count, newLines.count)
        return processDiffWithContext(diffLines)
    }

    // Previous compareFiles method remains the same
    func compareFiles(oldPath: String, newPath: String) -> String {
        let oldContent = readFile(from: oldPath)
        let newContent = readFile(from: newPath)
        return compareLines(oldContent, newContent)
    }
}
