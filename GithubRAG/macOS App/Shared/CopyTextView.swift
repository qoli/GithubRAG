//
//  CopyTextView.swift
//  GithubRAG
//
//  Created by 黃佁媛 on 2025/1/11.
//

import SwiftUI

struct CopyTextView: View {
    @Binding var copyableText: String

    var body: some View {
        Text(copyableText)

        Spacer()

        Button(action: {
            let pasteboard = NSPasteboard.general
            pasteboard.clearContents()
            pasteboard.setString(copyableText, forType: .string)
        }) {
            Image(systemName: "doc.on.doc")
                .foregroundColor(.blue)
        }
        .buttonStyle(.plain)
        .help("Copy to clipboard")
    }
}
