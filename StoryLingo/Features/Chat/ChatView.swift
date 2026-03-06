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

    var body: some View {
        PageScaffold(
            title: vm.story.title ?? "New Story",
            subtitle: "Hold the microphone to speak",
            contentHorizontalPadding: 2,
            showsBackButton: true,
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
        VStack(spacing: 10) {
            Text(vm.isRecording ? "\(vm.recordingElapsedSeconds) / \(vm.maxRecordingSeconds) sec" : "Hold to speak")
                .font(.system(size: 15, weight: .semibold, design: .rounded))
                .foregroundStyle(vm.isRecording ? .primary : .secondary)

            HoldToRecordButton(
                isRecording: vm.isRecording,
                isDisabled: vm.isSending || vm.isSpeaking,
                onPress: {
                    Task { await vm.startRecording() }
                },
                onRelease: {
                    vm.stopRecording()
                },
                onCancel: {
                    vm.cancelRecording()
                }
            )
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 10)
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
        .padding(.bottom, 10)
    }
}

private struct HoldToRecordButton: View {
    let isRecording: Bool
    let isDisabled: Bool
    let onPress: () -> Void
    let onRelease: () -> Void
    let onCancel: () -> Void

    @State private var didStartPress = false
    @State private var dragOffset: CGSize = .zero
    @State private var isOverCancelZone = false

    private let cancelThreshold: CGFloat = -120
    private let trashXOffset: CGFloat = -110

    private var progressToCancel: CGFloat {
        min(max(abs(dragOffset.width) / abs(cancelThreshold), 0), 1)
    }

    private var micScale: CGFloat {
        1.0 - (0.42 * progressToCancel)
    }

    private var trashCircleScale: CGFloat {
        isOverCancelZone ? 1.0 : (0.82 + 0.18 * progressToCancel)
    }

    private var trashCircleOpacity: Double {
        isRecording || didStartPress ? (isOverCancelZone ? 1.0 : 0.35 + 0.45 * Double(progressToCancel)) : 0
    }

    var body: some View {
        ZStack {
            if didStartPress || isRecording {
                HStack(spacing: 12) {
                    ZStack {
                        Circle()
                            .stroke(
                                isOverCancelZone ? Color.red : Color.secondary.opacity(0.35),
                                lineWidth: isOverCancelZone ? 3 : 2
                            )
                            .frame(width: 58, height: 58)
                            .scaleEffect(trashCircleScale)
                            .opacity(trashCircleOpacity)

                        Circle()
                            .fill(isOverCancelZone ? Color.red.opacity(0.12) : Color.clear)
                            .frame(width: 58, height: 58)
                            .scaleEffect(trashCircleScale)
                            .opacity(trashCircleOpacity)

                        Image(systemName: "trash")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundStyle(isOverCancelZone ? .red : .secondary)
                            .scaleEffect(isOverCancelZone ? 1.08 : 1.0)
                    }
                    .frame(width: 60, height: 60)

                    HStack(spacing: 2) {
                        Image(systemName: "chevron.left")
                        Image(systemName: "chevron.left")
                        Image(systemName: "chevron.left")
                    }
                    .font(.system(size: 15, weight: .bold))
                    .foregroundStyle(isOverCancelZone ? .red : .secondary.opacity(0.75))
                    .opacity(isOverCancelZone ? 0.72 : 1.0)
                }
                .offset(x: trashXOffset)
                .transition(.opacity)
            }

            Circle()
                .fill(isDisabled ? Color.gray.opacity(0.35) : (isRecording ? Color.red : Color.accentColor))
                .frame(width: 720, height: 72)
                .overlay(
                    Image(systemName: isRecording ? "waveform" : "mic.fill")
                        .font(.system(size: 24, weight: .semibold))
                        .foregroundStyle(.white)
                )
                .scaleEffect((isRecording ? 1.06 : 1.0) * micScale)
                .offset(x: dragOffset.width)
                .opacity(isOverCancelZone ? 0.92 : 1.0)
                .animation(.spring(response: 0.22, dampingFraction: 0.78), value: isRecording)
                .animation(.spring(response: 0.22, dampingFraction: 0.78), value: dragOffset)
                .animation(.spring(response: 0.22, dampingFraction: 0.78), value: isOverCancelZone)
                .contentShape(Circle())
                .simultaneousGesture(
                    DragGesture(minimumDistance: 0)
                        .onChanged { value in
                            guard !isDisabled else { return }

                            if !didStartPress {
                                didStartPress = true
                                onPress()
                            }

                            let x = min(0, value.translation.width)
                            dragOffset = CGSize(width: x, height: 0)

                            let micCenterX = x
                            let distanceToTrash = abs(micCenterX - trashXOffset)
                            isOverCancelZone = distanceToTrash < 36
                        }
                        .onEnded { _ in
                            guard didStartPress else { return }

                            let shouldCancel = isOverCancelZone

                            didStartPress = false
                            dragOffset = .zero
                            isOverCancelZone = false

                            if shouldCancel {
                                onCancel()
                            } else {
                                onRelease()
                            }
                        }
                )
        }
        .frame(width: 250, height: 80)
    }
}
