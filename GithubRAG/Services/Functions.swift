//
//  Functions.swift
//  GithubRAG
//
//  Created by 黃佁媛 on 2025/1/10.
//

import Foundation
import SwiftUI

let itemFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .short
    formatter.timeStyle = .medium
    return formatter
}()

func requestAccessToFolder(filePath: String?, completion: @escaping (URL?) -> Void) {
    let openPanel = NSOpenPanel()
    openPanel.canChooseFiles = false
    openPanel.canChooseDirectories = true
    openPanel.allowsMultipleSelection = false
    openPanel.prompt = "Select Folder"

    if let filePath {
        openPanel.directoryURL = URL(fileURLWithPath: filePath)
        openPanel.representedURL = URL(fileURLWithPath: filePath)
    }

    openPanel.begin { result in
        if result == .OK, let url = openPanel.url {
            _ = url.startAccessingSecurityScopedResource()

            completion(url)
        } else {
            completion(nil)
        }
    }
}
