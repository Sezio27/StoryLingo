//
//  StoryDetailView.swift
//  StoryLingo
//
//  Created by Jakob Jacobsen on 14/02/2026.
//

import SwiftUI

struct StoryDetailView: View {
    enum Tab: String, CaseIterable {
        case chat = "Chat History"
        case images = "Images"
    }

    let title: String
    let relativeTime: String
    let messageCount: Int

    @State private var selectedTab: Tab = .chat

    // Mock messages (replace with Core Data later)
    private let messages: [MockMessage] = [
        .init(isUser: false, text: "Bonjour! Bienvenue au marché. Qu'est-ce que vous cherchez?", time: "10:00 AM"),
        .init(isUser: true,  text: "Je cherche des tomates et du pain.", time: "10:01 AM"),
        .init(isUser: false, text: "Excellent! Les tomates sont très fraîches aujourd'hui.", time: "10:01 AM")
    ]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {

                header

                segmented

                Group {
                    switch selectedTab {
                    case .chat:
                        chatTab
                    case .images:
                        imagesTab
                    }
                }
                .padding(.top, 6)

                Spacer(minLength: 24)
            }
            .padding(.horizontal, 22)
            .padding(.top, 8)
        }
        .background(Color(.systemGroupedBackground))
        .navigationBarTitleDisplayMode(.inline)
        .safeAreaInset(edge: .bottom) {
            continueButton
        }
    }

    // MARK: - Header

    private var header: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.system(size: 28, weight: .bold, design: .rounded))

            HStack(spacing: 18) {
                Label(relativeTime, systemImage: "clock")
                    .font(.system(size: 12))
                    .foregroundStyle(.secondary)

                Label("\(messageCount) messages", systemImage: "bubble.left")
                    .font(.system(size: 12))
                    .foregroundStyle(.secondary)
            }
        }
    }

    // MARK: - Segmented control (pill style)

    private var segmented: some View {
        HStack(spacing: 0) {
            ForEach(Tab.allCases, id: \.self) { tab in
                Button {
                    withAnimation(.spring(response: 0.25, dampingFraction: 0.9)) {
                        selectedTab = tab
                    }
                } label: {
                    Text(tab.rawValue)
                        .font(.system(size: 14, weight: .semibold, design: .rounded))
                        .foregroundStyle(selectedTab == tab ? .primary : .secondary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background {
                            if selectedTab == tab {
                                RoundedRectangle(cornerRadius: 14, style: .continuous)
                                    .fill(Color(.systemBackground))
                                    .shadow(color: .black.opacity(0.06), radius: 8, y: 4)
                            }
                        }
                }
                .buttonStyle(.plain)
            }
        }
        .padding(6)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(Color(.secondarySystemGroupedBackground))
        )
    }

    // MARK: - Chat tab

    private var chatTab: some View {
        VStack(spacing: 18) {
            Text("Story started")
                .font(.system(size: 14, weight: .regular, design: .rounded))
                .foregroundStyle(.secondary)
                .padding(.top, 8)

            ForEach(messages) { msg in
                VStack(alignment: msg.isUser ? .trailing : .leading, spacing: 8) {
                    ChatBubble(text: msg.text, isUser: msg.isUser)

                    Text(msg.time)
                        .font(.system(size: 12))
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity, alignment: msg.isUser ? .trailing : .leading)
                }
            }

            Spacer(minLength: 120) // room above bottom button inset
        }
    }

    // MARK: - Images tab (placeholder)

    private var imagesTab: some View {
        VStack(spacing: 12) {
            Text("Images")
                .font(.system(size: 20, weight: .semibold, design: .rounded))
                .frame(maxWidth: .infinity, alignment: .leading)

            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(Color(.systemBackground))
                .frame(height: 160)
                .overlay(
                    VStack(spacing: 8) {
                        Image(systemName: "photo.on.rectangle.angled")
                            .font(.system(size: 30, weight: .semibold))
                            .foregroundStyle(.secondary)

                        Text("Image generation coming soon")
                            .font(.system(size: 16))
                            .foregroundStyle(.secondary)
                    }
                )
                .shadow(color: .black.opacity(0.06), radius: 10, y: 6)

            Spacer(minLength: 120)
        }
        .padding(.top, 6)
    }

    // MARK: - Continue button (bottom inset)

    private var continueButton: some View {
        VStack {
            Button {
                // TODO: continue story
            } label: {
                HStack(spacing: 12) {
                    Image(systemName: "play.fill")
                        .font(.system(size: 14, weight: .semibold))
                    Text("Continue Story")
                        .font(.system(size: 14, weight: .semibold, design: .rounded))
                }
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 18)
                .background(
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .fill(Color.blue)
                )
            }
            .buttonStyle(.plain)
            .padding(.horizontal, 22)
            .padding(.vertical, 14)
        }
        .background(.ultraThinMaterial)
    }
}

// MARK: - Bubble

private struct ChatBubble: View {
    let text: String
    let isUser: Bool

    var body: some View {
        Text(text)
            .font(.system(size: 14, weight: .regular, design: .rounded))
            .foregroundStyle(isUser ? .white : .primary)
            .padding(.horizontal, 18)
            .padding(.vertical, 14)
            .background(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(isUser ? Color.blue : Color(.systemBackground))
                    .shadow(color: .black.opacity(0.06), radius: 10, y: 6)
            )
            .frame(maxWidth: .infinity, alignment: isUser ? .trailing : .leading)
            .padding(.top, 6)
    }
}

// MARK: - Mock model

private struct MockMessage: Identifiable {
    let id = UUID()
    let isUser: Bool
    let text: String
    let time: String
}

#Preview {
    NavigationStack {
        StoryDetailView(
            title: "A Trip to the Market",
            relativeTime: "2 hours ago",
            messageCount: 24
        )
    }
}
