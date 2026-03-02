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
                            ChatBubble(text: msg.text ?? "—", isUser: msg.isUser)
                                .id(msg.objectID)
                        }

                        // keeps last bubble from hiding behind the composer
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
        }.toolbar(.hidden, for: .tabBar) 
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
                vm.send()
            } label: {
                Image(systemName: "arrow.up")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(.white)
                    .frame(width: 44, height: 44)
                    .background(Circle().fill(Color.accentColor))
            }
            .buttonStyle(.plain)
            .disabled(vm.composerText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            .opacity(vm.composerText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? 0.4 : 1)
        }
        .padding(.horizontal, 22)
        .padding(.top, 10)
        .padding(.bottom, 12) // sits nicely above the tab bar
        .background(Color(.systemGroupedBackground)) // <-- matches your screen bg
        .overlay(Divider(), alignment: .top)         // subtle separation, no grey box
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

    var body: some View {
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
            .frame(maxWidth: .infinity, alignment: isUser ? .trailing : .leading)
            .padding(.horizontal, 22)
    }
}
