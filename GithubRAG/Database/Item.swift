//
//  Item.swift
//  GithubRAG
//
//  Created by 黃佁媛 on 2025/1/10.
//

import Foundation

extension Item {
    var folderName: String {
        let url = URL(string: folderURL ?? "")
        return url?.lastPathComponent ?? "nil"
    }
}
