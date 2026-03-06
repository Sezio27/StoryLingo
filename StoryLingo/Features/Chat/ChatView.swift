//
//  ChatView.swift
//  StoryLingo
//
//  Created by Jakob Jacobsen on 06/03/2026.
//

import SwiftUI
import CoreData

struct ChatView: View {
    @StateObject var vm: ChatViewModel
    @FocusState private var isFocused: Bool

    var body: some View {
        PageScaffold(
            title: vm.story.title ?? "New Story",
            subtitle: "Type messages to build your story",
            showsBackButton: true
        ) {
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(spacing: 14) {
                        ForEach(vm.messages, id: \.objectID) { msg in
                            ChatBubble(
                                text: msg.text ?? "—",
                                isUser: msg.isUser,
                                translation: vm.translatedBubble(for: msg)
                            )
                            .id(msg.objectID)
                        }

                        Spacer(minLength: 10)
                    }
                    .padding(.top, 6)
                }
                .background(Color(.systemGroupedBackground))
                .onAppear {
                    vm.load()
                    scrollToBottom(proxy)
                }
                .onChange(of: vm.messages.count) { _ in
                    scrollToBottom(proxy)
                }
                .safeAreaInset(edge: .bottom, spacing: 0) {
                    composer
                }
            }
        }
        .toolbar(.hidden, for: .tabBar)
        .alert("OpenAI error", isPresented: Binding(
            get: { vm.errorMessage != nil },
            set: { if !$0 { vm.errorMessage = nil } }
        )) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(vm.errorMessage ?? "")
        }
    }

    private var composer: some View {
        HStack(spacing: 10) {
            TextField("Message", text: $vm.composerText, axis: .vertical)
                .textFieldStyle(.plain)
                .padding(.horizontal, 14)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(Color(.systemBackground))
                        .overlay(
                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                                .stroke(Color.black.opacity(0.06), lineWidth: 1)
                        )
                )
                .focused($isFocused)

            Button {
                Task { await vm.toggleRecording() }
            } label: {
                Image(systemName: vm.isRecording ? "stop.fill" : "mic.fill")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(.white)
                    .frame(width: 44, height: 44)
                    .background(Circle().fill(vm.isRecording ? Color.red : Color.accentColor))
            }
            .buttonStyle(.plain)

            let isEmpty = vm.composerText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            let isDisabled = isEmpty || vm.isSending || vm.isRecording

            Button {
                Task { await vm.send() }
            } label: {
                Group {
                    if vm.isSending {
                        ProgressView()
                            .tint(.white)
                    } else {
                        Image(systemName: "arrow.up")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(.white)
                    }
                }
                .frame(width: 44, height: 44)
                .background(Circle().fill(Color.accentColor))
            }
            .buttonStyle(.plain)
            .disabled(isDisabled)
            .opacity(isDisabled ? 0.4 : 1)
        }
        .padding(.horizontal, 22)
        .padding(.top, 10)
        .padding(.bottom, 12)
        .background(Color(.systemGroupedBackground))
        .overlay(Divider(), alignment: .top)
    }

    private func scrollToBottom(_ proxy: ScrollViewProxy) {
        guard let last = vm.messages.last else { return }
        withAnimation(.easeOut(duration: 0.2)) {
            proxy.scrollTo(last.objectID, anchor: .bottom)
        }
    }
}

private struct ChatBubble: View {
    let text: String
    let isUser: Bool
    let translation: BubbleTranslation?

    var body: some View {
        VStack(
            alignment: isUser ? .trailing : .leading,
            spacing: 6
        ) {
            Text(text)
                .font(.system(size: 14, weight: .regular, design: .rounded))
                .foregroundStyle(isUser ? .white : .primary)
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .fill(isUser ? Color.blue : Color(.systemBackground))
                        .shadow(color: .black.opacity(0.06), radius: 10, y: 6)
                )

            if let translation {
                HStack(spacing: 6) {
                    Text(translation.targetLanguageFlag)

                    Text("“\(translation.text)”")
                        .italic()
                }
                .font(.system(size: 13, weight: .medium, design: .rounded))
                .foregroundStyle(.secondary)
                .padding(.horizontal, 8)
            }
        }
        .frame(maxWidth: .infinity, alignment: isUser ? .trailing : .leading)
        .padding(.horizontal, 22)
    }
}
