//
//  ListButton.swift
//  GithubRAG
//
//  Created by 黃佁媛 on 2025/1/11.
//

import SwiftUI

struct ListButton: View {
    let completionHandler: () -> Void
    let text: String

    init(text: String, completionHandler: @escaping () -> Void) {
        self.text = text
        self.completionHandler = completionHandler
    }

    var body: some View {
        Button {
            completionHandler()
        } label: {
            Text(text)
                .lineLimit(1)
                .truncationMode(.head)
        }
        .buttonStyle(.link)
    }
}

#Preview {
    ListButton(text: "View+debugOnlyModifier.swift") { }
}
