import SwiftUI
internal import Combine

@MainActor
final class ChatViewModel: ObservableObject {
    @Published var messages: [Message] = []
    @Published var composerText: String = ""
    @Published var isSending: Bool = false
    @Published var errorMessage: String?

    let story: Story
    private let repo: ChatRepository
    private let llm: LLMClient

    init(story: Story, repo: ChatRepository, llm: LLMClient) {
        self.story = story
        self.repo = repo
        self.llm = llm
    }

    func load() {
        do {
            messages = try repo.fetchMessages(for: story)
        } catch {
            assertionFailure("Failed to fetch messages: \(error)")
        }
    }

    func send() async {
        let text = composerText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else { return }

        composerText = ""
        errorMessage = nil
        isSending = true
        defer { isSending = false }

        do {
            // 1) Save user message
            _ = try repo.addMessage(text: text, isUser: true, to: story)

            // 2) Build context (last N messages)
            let history = try repo.fetchMessages(for: story)
            messages = history

            let tail = history.suffix(30)

            var prompt: [LLMMessage] = []

            // Optional: steer model (keep short)
            prompt.append(.init(
                role: .developer,
                content: "You are StoryLingo. Continue the story and reply concisely. Ask one question to keep the story going."
            ))

            for m in tail {
                prompt.append(.init(
                    role: m.isUser ? .user : .assistant,
                    content: m.text ?? ""
                ))
            }
            print("Calling OpenAI with \(prompt.count) messages")
            // 3) Call LLM
            let reply = try await llm.generateText(
                messages: prompt,
                model: "gpt-5.2",
                temperature: 0.7,
                maxOutputTokens: 250
            )

            // 4) Save assistant message
            _ = try repo.addMessage(text: reply, isUser: false, to: story)

            // 5) Refresh
            messages = try repo.fetchMessages(for: story)

        } catch {
            print("OpenAI/send error:", error)
            errorMessage = (error as NSError).localizedDescription
        }
    }
}
