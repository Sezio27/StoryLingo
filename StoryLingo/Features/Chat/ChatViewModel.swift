//
//  ChatViewModel.swift
//  StoryLingo
//
//  Created by Jakob Jacobsen on 02/03/2026.
//

import SwiftUI
internal import Combine

@MainActor
final class ChatViewModel: ObservableObject {
    @Published var messages: [Message] = []
    @Published var composerText: String = ""

    let story: Story
    private let repo: ChatRepository

    init(story: Story, repo: ChatRepository) {
        self.story = story
        self.repo = repo
    }

    func load() {
        do {
            messages = try repo.fetchMessages(for: story)
        } catch {
            assertionFailure("Failed to fetch messages: \(error)")
        }
    }

    func send() {
        let text = composerText
        composerText = ""

        do {
            _ = try repo.addMessage(text: text, isUser: true, to: story)
            messages = try repo.fetchMessages(for: story)
        } catch {
            // If empty send, just ignore; otherwise assert
            // (you can improve this later with proper UI errors)
        }
    }
}
