# GitRAG Commit Agent

This is a RAG Agent project based on Ollama, designed to read git diff logs and allow an LLM to respond to modification content.

The project utilizes SwiftUI and SwiftGit2, and file access complies with App Sandbox requirements.

![appImage](https://raw.githubusercontent.com/qoli/RAG_Commit_Agent/refs/heads/main/assets/SCR-20250112-dgdc.jpeg)

## Usage Instructions

1. Ensure that you have installed Ollama and downloaded the `llama3.2:latest` model.

   ```swift
   let ollamaURL = URL(string: "http://127.0.0.1:11434/api/generate")!
   var request = URLRequest(url: ollamaURL)
   request.httpMethod = "POST"
   request.addValue("application/json", forHTTPHeaderField: "Content-Type")

   let parameters: [String: Any] = [
       "model": "llama3.2:latest",
       "prompt": prompt,
       "stream": false,
   ]
   ```

2. Add a folder.
   The folder must already be a Git project.

3. Select the files to be added to the RAG database.
   By default, all files are pre-selected.

4. Choose a Query.
   This will communicate with Llama and generate Git Commit messages.

# GitRAG Commit Agent

這是一個基於 Ollama 的 RAG Agent 項目，他的功能是用於閱讀 git diff 的日誌，讓 LLM 回答修改內容。

項目使用 SwiftUI，SwiftGit2，文件訪問符合 App Sandbox 要求。

## 使用說明

1. 確認已經安裝 ollama 以及下載 llama3.2:latest 模型。

```
let ollamaURL = URL(string: "http://127.0.0.1:11434/api/generate")!
var request = URLRequest(url: ollamaURL)
request.httpMethod = "POST"
request.addValue("application/json", forHTTPHeaderField: "Content-Type")

let parameters: [String: Any] = [
    "model": "llama3.2:latest",
    "prompt": prompt,
    "stream": false,
]
```

2. 添加文件夾
   要求文件夾已經是 Git 項目

3. 勾選需要添加到 Rag 數據庫的文件。
   默認已經默認全部勾選

4. 選擇 Query
   那麼就會和 llama 通信並生成 Git Commit 信息

## 感謝

- https://github.com/DonTizi/Swiftrag
- https://github.com/mbernson/SwiftGit2/tree/swift-package-manager
