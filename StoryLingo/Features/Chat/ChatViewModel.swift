//
//  ChatViewModel.swift
//  StoryLingo
//
//  Created by Jakob Jacobsen on 06/03/2026.
//

import SwiftUI
import CoreData
import AVFoundation
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
    @Published var isSpeaking = false
    @Published var recordingElapsedSeconds: Int = 0
    @Published var maxRecordingSeconds: Int = 15
    @Published var replyCards: [ReplyCardItem] = []
    @Published var selectedReplyCardID: UUID?
    @Published var lastSubmittedUserMessageID: NSManagedObjectID?
    
    let story: Story

    private let speechService: SpeechRecognizerServiceProtocol
    private let speechSynthesizer: any SpeechSynthesizing
    private let audioPlayer: AudioPlaying
    private let context: NSManagedObjectContext
    private let repo: ChatRepository
    private let llm: LLMClient
    private let settingsRepository: AppSettingsRepositoryProtocol
    private let translator: TranslatorClient
    private let replyGenerator: ChatReplyGenerating
    private let replyCardGenerator: ReplyCardGenerating
    private var hasSubmittedCurrentRecording = false
    private var recordingTimerTask: Task<Void, Never>?
    private var shouldSendAfterRecording = true
    private let statsRepository: StatsRepository
    private let replyCardAudioCache = TemporarySpeechFileCache()



    
    init(
        story: Story,
        context: NSManagedObjectContext,
        repo: ChatRepository,
        llm: LLMClient,
        settingsRepository: AppSettingsRepositoryProtocol = AppSettingsRepository(),
        translator: TranslatorClient? = nil,
        replyGenerator: ChatReplyGenerating? = nil,
        replyCardGenerator: ReplyCardGenerating? = nil,
        speechService: SpeechRecognizerServiceProtocol,
        speechSynthesizer: any SpeechSynthesizing,
        audioPlayer: AudioPlaying? = nil,
        statsRepository: StatsRepository
    ) {
        self.story = story
        self.context = context
        self.repo = repo
        self.llm = llm
        self.settingsRepository = settingsRepository
        self.translator = translator ?? LLMTranslatorClient(llm: llm)
        self.replyGenerator = replyGenerator ?? LLMChatReplyGenerator(llm: llm)
        self.replyCardGenerator = replyCardGenerator ?? LLMReplyCardGenerator(llm: llm)
        self.speechService = speechService
        self.speechSynthesizer = speechSynthesizer
        self.audioPlayer = audioPlayer ?? AudioPlaybackService()
        self.statsRepository = statsRepository
    }
    
    var visibleCategoryCards: [ReplyCardItem] {
        replyCards.filter { $0.kind == .category }
    }
    
    func refreshReplyCards() async {
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
                    code: 2,
                    userInfo: [NSLocalizedDescriptionKey: "Missing native or target language."]
                )
            }

            let difficulty = DifficultyLevel(rawValue: settings.level) ?? .intermediate
            let categories = Array(CardCategory.allCases.shuffled().prefix(3))
            let history = messages.suffix(4).map {
                LLMMessage(role: $0.isUser ? .user : .assistant, content: $0.text ?? "")
            }

            let generated = try await replyCardGenerator.generateReplyCards(
                categories: categories,
                recentHistory: history,
                context: ReplyCardPromptContext(
                    nativeLanguageCode: nativeCode,
                    nativeLanguageName: nativeName,
                    targetLanguageCode: targetCode,
                    targetLanguageName: targetName,
                    difficulty: difficulty
                )
            )

            replyCards = generated
            selectedReplyCardID = nil
        } catch {
            print("Reply card generation error:", error)
            replyCards = MockReplyCardFactory.makeHand()
            selectedReplyCardID = nil
        }
    }

    func selectReplyCard(_ card: ReplyCardItem) {
        selectedReplyCardID = card.id
    }



    func submitCustomReply(_ text: String) async -> BubbleTranslation? {
        await sendMessage(text)

        guard let messageID = lastSubmittedUserMessageID else {
            return nil
        }

        return translatedBubbles[messageID]
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
            Task { await refreshReplyCards() }
        } catch {
            assertionFailure("Failed to fetch messages: \(error)")
        }
    }

    func translatedBubble(for message: Message) -> BubbleTranslation? {
        translatedBubbles[message.objectID]
    }
    
    func startRecording() async {
        guard !isRecording else { return }

        errorMessage = nil

        let granted = await speechService.requestPermissions()
        guard granted else {
            errorMessage = "Microphone permission was denied."
            return
        }

        let localeIdentifier = speechLocaleIdentifier(for: story.language?.code ?? "en")

        do {
            audioPlayer.stop()
            speechTranscript = ""
            hasSubmittedCurrentRecording = false
            recordingElapsedSeconds = 0
            shouldSendAfterRecording = true

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
                    self.stopRecordingTimer()

                    guard self.shouldSendAfterRecording else {
                        self.speechTranscript = ""
                        self.shouldSendAfterRecording = true
                        return
                    }

                    guard !finalText.isEmpty else { return }
                    guard !self.hasSubmittedCurrentRecording else { return }

                    self.hasSubmittedCurrentRecording = true
                    self.speechTranscript = ""
                    self.shouldSendAfterRecording = true

                    Task {
                        await self.sendMessage(finalText)
                    }
                }
            )

            isRecording = true
            startRecordingTimer()
        } catch {
            errorMessage = (error as NSError).localizedDescription
            isRecording = false
            stopRecordingTimer()
        }
    }
    
    func cancelRecording() {
        guard isRecording else { return }
        shouldSendAfterRecording = false
        speechService.cancelRecording()
        isRecording = false
        stopRecordingTimer()
        speechTranscript = ""
    }

    func stopRecording() {
        guard isRecording else { return }
        speechService.stopRecording()
        isRecording = false
        stopRecordingTimer()
    }
    
    private func startRecordingTimer() {
        stopRecordingTimer()

        recordingTimerTask = Task { [weak self] in
            guard let self else { return }

            while !Task.isCancelled && self.isRecording && self.recordingElapsedSeconds < self.maxRecordingSeconds {
                try? await Task.sleep(nanoseconds: 1_000_000_000)

                guard !Task.isCancelled, self.isRecording else { return }

                self.recordingElapsedSeconds += 1
            }
        }
    }

    private func stopRecordingTimer() {
        recordingTimerTask?.cancel()
        recordingTimerTask = nil
        recordingElapsedSeconds = 0
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
                lastSubmittedUserMessageID = savedUserMessage.objectID
                if let targetCode = story.language?.code {
                    try statsRepository.recordUserMessage(
                        text: text,
                        languageCode: targetCode,
                        at: savedUserMessage.timestamp ?? Date()
                    )
                }

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
                    .init(role: $0.isUser ? .user : .assistant, content: $0.text ?? "")
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
                    targetLanguageFlag: nativeLanguage.flagEmoji ?? "",
                    text: replyResult.translatedText
                )

                try persistTranslation(assistantTranslation, for: savedAssistantMessage)
                messages = try repo.fetchMessages(for: story)
                // regenerate cards after each AI response
                await refreshReplyCards()
                isSending = false
                await speakAssistantReply(replyResult.replyText, languageCode: targetCode)
            } catch {
                isSending = false
                print("Send error:", error)
                errorMessage = (error as NSError).localizedDescription
            }
        }
    
    private func speakAssistantReply(_ text: String, languageCode: String) async {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }

        do {
            isSpeaking = true

            let stream = speechSynthesizer.synthesizeSpeechStream(
                from: trimmed,
                voice: voiceForLanguage(languageCode),
                instructions: makeTTSInstructions(for: trimmed),
                speed: 1.0
            )

            try await audioPlayer.playPCMStream(stream)
            
            isSpeaking = false
        } catch {
            print("TTS stream error:", error)
            isSpeaking = false
        }
    }
    
    private func makeTTSInstructions(for text: String) -> String {
        let genre = story.genre ?? ""
        let theme = story.theme ?? ""
        let place = story.place ?? ""

        return """
        Read this as part of an interactive story.
        Genre: \(genre)
        Theme: \(theme)
        Setting: \(place)
        Match the delivery to the story context and the meaning of the text.
        Use natural storytelling for narration.
        Use a more conversational delivery for spoken dialogue.
        Differentiate narration and dialogue clearly.
        Avoid a flat reading.
        """
    }

    private func voiceForLanguage(_ languageCode: String) -> String {
        switch languageCode {
        case "en": return "alloy"
        case "da": return "alloy"
        case "fr": return "verse"
        case "es": return "verse"
        case "de": return "alloy"
        default: return "alloy"
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
    

    func speakCustomTranslation(_ translation: BubbleTranslation) async {
        let spokenText = translation.text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !spokenText.isEmpty else { return }

        let languageCode = translation.targetLanguageCode
        let voice = voiceForLanguage(languageCode)

        let cacheKey = TemporarySpeechFileCache.Key(
            text: spokenText,
            languageCode: languageCode,
            voice: voice,
            speed: 1.0,
            instructions: "Speak this learner translation clearly and naturally."
        )

        do {
            audioPlayer.stop()

            if let cachedURL = replyCardAudioCache.cachedURL(for: cacheKey) {
                try audioPlayer.playAudioFile(at: cachedURL)
                return
            }

            let audioData = try await speechSynthesizer.synthesizeSpeech(
                from: spokenText,
                voice: voice,
                instructions: "Speak this learner translation clearly and naturally.",
                speed: 1.0
            )

            let fileURL = try replyCardAudioCache.store(audioData, for: cacheKey)
            try audioPlayer.playAudioFile(at: fileURL)
        } catch {
            print("Custom translation TTS error:", error)
            errorMessage = (error as NSError).localizedDescription
        }
    }
    func speakReplyCard(_ card: ReplyCardItem) async {
        let spokenText = (card.sourceText ?? card.text)
            .trimmingCharacters(in: .whitespacesAndNewlines)

        guard !spokenText.isEmpty else { return }

        let languageCode = story.language?.code ?? "en"
        let voice = voiceForLanguage(languageCode)
        let instructions = makeReplyCardTTSInstructions()

        let cacheKey = TemporarySpeechFileCache.Key(
            text: spokenText,
            languageCode: languageCode,
            voice: voice,
            speed: 1.0,
            instructions: instructions
        )

        do {
            audioPlayer.stop()

            if let cachedURL = replyCardAudioCache.cachedURL(for: cacheKey) {
                try audioPlayer.playAudioFile(at: cachedURL)
                return
            }

            let audioData = try await speechSynthesizer.synthesizeSpeech(
                from: spokenText,
                voice: voice,
                instructions: instructions,
                speed: 1.0
            )

            let fileURL = try replyCardAudioCache.store(audioData, for: cacheKey)
            try audioPlayer.playAudioFile(at: fileURL)
        } catch {
            print("Reply-card TTS error:", error)
            errorMessage = (error as NSError).localizedDescription
        }
    }

    private func makeReplyCardTTSInstructions() -> String {
        let genre = story.genre ?? ""
        let theme = story.theme ?? ""
        let place = story.place ?? ""

        return """
        Speak this short learner phrase clearly and naturally.
        Genre: \(genre)
        Theme: \(theme)
        Setting: \(place)
        Keep the pronunciation easy to imitate.
        Do not add extra narration before or after the phrase.
        """
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
    
    deinit {
            recordingTimerTask?.cancel()
        }
    
    
}
