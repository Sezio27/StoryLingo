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
    @Published var isRecording = false
    @Published var speechTranscript = ""

    let story: Story
    
    private let speechService: SpeechRecognizerServiceProtocol
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
        replyGenerator: ChatReplyGenerating? = nil,
        speechService: SpeechRecognizerServiceProtocol? = nil
    ) {
        self.story = story
        self.context = context
        self.repo = repo
        self.llm = llm
        self.settingsRepository = settingsRepository
        self.translator = translator ?? LLMTranslatorClient(llm: llm)
        self.replyGenerator = replyGenerator ?? LLMChatReplyGenerator(llm: llm)
        self.speechService = speechService ?? SpeechRecognizerService()
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
    
    func toggleRecording() async {
        if isRecording {
            stopRecording()
            return
        }

        errorMessage = nil

        let granted = await speechService.requestPermissions()
        guard granted else {
            errorMessage = "Microphone or speech recognition permission was denied."
            return
        }

        let localeIdentifier = speechLocaleIdentifier(for: story.language?.code ?? "en")

        do {
            speechTranscript = ""
            try speechService.startRecording(
                localeIdentifier: localeIdentifier,
                onText: { [weak self] text in
                    guard let self else { return }
                    self.speechTranscript = text
                },
                onFinish: { [weak self] in
                    guard let self else { return }

                    let finalText = self.speechTranscript.trimmingCharacters(in: .whitespacesAndNewlines)
                    self.isRecording = false

                    guard !finalText.isEmpty else { return }

                    Task {
                        await self.sendMessage(finalText)
                        self.speechTranscript = ""
                    }
                }
            )
            isRecording = true
        } catch {
            errorMessage = (error as NSError).localizedDescription
            isRecording = false
        }
    }

    func stopRecording() {
        speechService.stopRecording()
        isRecording = false
    }

    func send() async {
        let text = composerText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else { return }

        composerText = ""
        await sendMessage(text)
    }

    private func sendMessage(_ rawText: String) async {
        let text = rawText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else { return }

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

            let savedUserMessage = try repo.addMessage(text: text, isUser: true, to: story)

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

            let history = try repo.fetchMessages(for: story)
            messages = history

            let tail = history.suffix(30)
            let llmHistory: [LLMMessage] = tail.map {
                .init(
                    role: $0.isUser ? .user : .assistant,
                    content: $0.text ?? ""
                )
            }

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

            let savedAssistantMessage = try repo.addMessage(
                text: replyResult.replyText,
                isUser: false,
                to: story
            )

            let assistantTranslation = BubbleTranslation(
                messageID: savedAssistantMessage.objectID,
                targetLanguageCode: nativeCode,
                targetLanguageFlag: nativeLanguage.flagEmoji ?? "🌐",
                text: replyResult.translatedText
            )

            try persistTranslation(assistantTranslation, for: savedAssistantMessage)

            messages = try repo.fetchMessages(for: story)

        } catch {
            print("Send error:", error)
            errorMessage = (error as NSError).localizedDescription
        }
    }
    
    private func speechLocaleIdentifier(for languageCode: String) -> String {
        switch languageCode {
        case "da": return "da-DK"
        case "en": return "en-US"
        case "fr": return "fr-FR"
        case "de": return "de-DE"
        case "es": return "es-ES"
        case "it": return "it-IT"
        case "ja": return "ja-JP"
        case "ko": return "ko-KR"
        case "ro": return "ro-RO"
        case "th": return "th-TH"
        default: return languageCode
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
