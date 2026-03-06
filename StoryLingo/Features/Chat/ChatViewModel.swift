//
//  ChatViewModel.swift
//  StoryLingo
//
//  Created by Jakob Jacobsen on 06/03/2026.
//

import SwiftUI
import CoreData
internal import Combine

@MainActor
final class ChatViewModel: ObservableObject {
    @Published var messages: [Message] = []
    @Published var composerText: String = ""
    @Published var isSending: Bool = false
    @Published var errorMessage: String?

    @Published private(set) var translatedBubbles: [NSManagedObjectID: BubbleTranslation] = [:]

    let story: Story

    private let context: NSManagedObjectContext
    private let repo: ChatRepository
    private let llm: LLMClient
    private let settingsRepository: AppSettingsRepositoryProtocol
    private let translator: TranslatorClient
    private let replyGenerator: ChatReplyGenerating

    init(
        story: Story,
        context: NSManagedObjectContext,
        repo: ChatRepository,
        llm: LLMClient,
        settingsRepository: AppSettingsRepositoryProtocol = AppSettingsRepository(),
        translator: TranslatorClient? = nil,
        replyGenerator: ChatReplyGenerating? = nil
    ) {
        self.story = story
        self.context = context
        self.repo = repo
        self.llm = llm
        self.settingsRepository = settingsRepository
        self.translator = translator ?? LLMTranslatorClient(llm: llm)
        self.replyGenerator = replyGenerator ?? LLMChatReplyGenerator(llm: llm)
    }

    func load() {
        do {
            messages = try repo.fetchMessages(for: story)

            translatedBubbles = Dictionary(
                uniqueKeysWithValues: messages.compactMap { message in
                    guard let translatedText = message.translatedTextSafe else {
                        return nil
                    }

                    let bubble = BubbleTranslation(
                        messageID: message.objectID,
                        targetLanguageCode: message.translatedLanguageCode ?? "",
                        targetLanguageFlag: message.translatedFlagEmoji ?? "🌐",
                        text: translatedText
                    )

                    return (message.objectID, bubble)
                }
            )
        } catch {
            assertionFailure("Failed to fetch messages: \(error)")
        }
    }

    func translatedBubble(for message: Message) -> BubbleTranslation? {
        translatedBubbles[message.objectID]
    }

    func send() async {
        let text = composerText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else { return }

        composerText = ""
        errorMessage = nil
        isSending = true
        defer { isSending = false }

        do {
            let settings = try settingsRepository.fetchOrCreate(in: context)

            guard
                let nativeLanguage = settings.nativeLanguage,
                let targetLanguage = story.language,
                let nativeCode = nativeLanguage.code,
                let nativeName = nativeLanguage.displayName,
                let targetCode = targetLanguage.code,
                let targetName = targetLanguage.displayName
            else {
                throw NSError(
                    domain: "ChatViewModel",
                    code: 1,
                    userInfo: [NSLocalizedDescriptionKey: "Missing native or target language."]
                )
            }

            let difficulty = DifficultyLevel(rawValue: settings.level) ?? .intermediate

            // 1) Save user message
            let savedUserMessage = try repo.addMessage(text: text, isUser: true, to: story)

            // 2) Translate user message and persist its translation bubble
            if let userTranslation = try await translateUserMessage(
                savedUserMessage,
                nativeLanguage: nativeLanguage,
                nativeCode: nativeCode,
                nativeName: nativeName,
                targetLanguage: targetLanguage,
                targetCode: targetCode,
                targetName: targetName
            ) {
                try persistTranslation(userTranslation, for: savedUserMessage)
            }

            // 3) Refresh history
            let history = try repo.fetchMessages(for: story)
            messages = history

            let tail = history.suffix(30)
            let llmHistory: [LLMMessage] = tail.map {
                .init(
                    role: $0.isUser ? .user : .assistant,
                    content: $0.text ?? ""
                )
            }

            // 4) Generate assistant reply + native-language translation in one call
            let replyResult = try await replyGenerator.generateReply(
                history: llmHistory,
                context: ChatPromptContext(
                    nativeLanguageCode: nativeCode,
                    nativeLanguageName: nativeName,
                    targetLanguageCode: targetCode,
                    targetLanguageName: targetName,
                    difficulty: difficulty
                )
            )

            // 5) Save assistant reply in target language
            let savedAssistantMessage = try repo.addMessage(
                text: replyResult.replyText,
                isUser: false,
                to: story
            )

            // 6) Persist assistant translation bubble
            let assistantTranslation = BubbleTranslation(
                messageID: savedAssistantMessage.objectID,
                targetLanguageCode: nativeCode,
                targetLanguageFlag: nativeLanguage.flagEmoji ?? "🌐",
                text: replyResult.translatedText
            )

            try persistTranslation(assistantTranslation, for: savedAssistantMessage)

            // 7) Refresh again
            messages = try repo.fetchMessages(for: story)

        } catch {
            print("Send error:", error)
            errorMessage = (error as NSError).localizedDescription
        }
    }

    private func translateUserMessage(
        _ message: Message,
        nativeLanguage: Language,
        nativeCode: String,
        nativeName: String,
        targetLanguage: Language,
        targetCode: String,
        targetName: String
    ) async throws -> BubbleTranslation? {
        guard let text = message.text?.trimmingCharacters(in: .whitespacesAndNewlines),
              !text.isEmpty else {
            return nil
        }

        let result = try await translator.translateForLearning(
            text: text,
            nativeLanguageCode: nativeCode,
            nativeLanguageName: nativeName,
            targetLanguageCode: targetCode,
            targetLanguageName: targetName
        )

        let flag: String
        if result.targetLanguageCode == nativeCode {
            flag = nativeLanguage.flagEmoji ?? "🌐"
        } else if result.targetLanguageCode == targetCode {
            flag = targetLanguage.flagEmoji ?? "🌐"
        } else {
            flag = "🌐"
        }

        return BubbleTranslation(
            messageID: message.objectID,
            targetLanguageCode: result.targetLanguageCode,
            targetLanguageFlag: flag,
            text: result.translatedText
        )
    }

    private func persistTranslation(_ translation: BubbleTranslation, for message: Message) throws {
        try repo.saveTranslation(translation, for: message)
        translatedBubbles[message.objectID] = translation
    }
}
