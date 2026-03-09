import SwiftUI
import CoreData

struct StoryDetailView: View {
    private let story: Story
    private let ctx: NSManagedObjectContext
    @StateObject private var vm: StoryDetailViewModel

    @Environment(\.dismiss) private var dismiss

    @State private var goToChat = false
    @State private var showDeleteConfirm = false
    @Environment(\.llmClient) private var llmClient
    @Environment(\.speechSynthesizer) private var speechSynthesizer
    @Environment(\.speechRecognizerService) private var speechRecognizerService
    
    init(story: Story, ctx: NSManagedObjectContext) {
        self.story = story
        self.ctx = ctx
        _vm = StateObject(
            wrappedValue: StoryDetailViewModel(
                story: story,
                repo: CoreDataStoriesRepository(ctx: ctx),
                ctx: ctx
            )
        )
    }

    var body: some View {
        PageScaffold(
            title: "Story",
            subtitle: "Details & history",
            scrolls: true,
            showsBackButton: true
        ) {
            VStack(spacing: 16) {

                // Hidden navigation to chat
                NavigationLink(isActive: $goToChat) {
                    ChatView(
                        vm: ChatViewModel(
                            story: story,
                            context: ctx,
                            repo: CoreDataChatRepository(ctx: ctx),
                            llm: llmClient,
                            speechService: speechRecognizerService,
                            speechSynthesizer: speechSynthesizer,
                            statsRepository: CoreDataStatsRepository(ctx: ctx)
                        )
                    )
                } label: { EmptyView() }
                .hidden()

                StoryInfoCard(vm: vm)

                ImagesPlaceholderCard()

                NewStoryButton(
                    title: "Open Chat",
                    systemImage: "bubble.left.and.bubble.right.fill",
                    trailingSparkle: false
                ) {
                    goToChat = true
                }

                Spacer(minLength: 24)

                Button {
                    showDeleteConfirm = true
                } label: {
                    Image(systemName: "trash")
                        .font(.system(size: 28, weight: .semibold))
                        .foregroundStyle(.red)
                        .padding(.vertical, 6)
                }
                .buttonStyle(.plain)
                .padding(.bottom, 10)
            }
            .padding(.top, 6)
        }
        .task { await vm.load() }
        .confirmationDialog("Delete story?", isPresented: $showDeleteConfirm, titleVisibility: .visible) {
            Button("Delete", role: .destructive) {
                Task {
                    await vm.deleteStory()
                    // If delete succeeded, repo saved -> pop back
                    if vm.errorMessage == nil {
                        dismiss()
                    }
                }
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This will permanently delete the story and its messages.")
        }
        .alert("Error", isPresented: Binding(
            get: { vm.errorMessage != nil },
            set: { if !$0 { vm.clearError() } }
        )) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(vm.errorMessage ?? "")
        }
    }
}

private struct StoryInfoCard: View {
    @ObservedObject var vm: StoryDetailViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(vm.titleText)
                .font(.system(size: 26, weight: .bold, design: .rounded))

            HStack(spacing: 18) {
                Label(vm.createdRelativeText, systemImage: "clock")
                    .font(.system(size: 12))
                    .foregroundStyle(.secondary)

                Label("\(vm.messageCount)", systemImage: "bubble.left")
                    .font(.system(size: 12))
                    .foregroundStyle(.secondary)
            }

            Text("Created: \(vm.createdExactText)")
                .font(.system(size: 12))
                .foregroundStyle(.secondary)

            Text("Last updated: \(vm.updatedRelativeText)")
                .font(.system(size: 12))
                .foregroundStyle(.secondary)

            if vm.genreText != nil || vm.themeText != nil {
                VStack(alignment: .leading, spacing: 6) {
                    if let genre = vm.genreText {
                        Text("Genre: \(genre)")
                    }
                    if let theme = vm.themeText {
                        Text("Theme: \(theme)")
                    }
                }
                .font(.system(size: 13, weight: .semibold, design: .rounded))
                .foregroundStyle(.secondary)
                .padding(.top, 4)
            }
        }
        .padding(18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.06), radius: 10, y: 6)
        )
    }
}

private struct ImagesPlaceholderCard: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Images")
                .font(.system(size: 18, weight: .bold, design: .rounded))

            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color(.secondarySystemGroupedBackground))
                .frame(height: 140)
                .overlay(
                    VStack(spacing: 8) {
                        Image(systemName: "photo.on.rectangle.angled")
                            .font(.system(size: 28, weight: .semibold))
                            .foregroundStyle(.secondary)
                        Text("Images will appear here when the story is finished")
                            .font(.system(size: 13, design: .rounded))
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 10)
                    }
                )
        }
        .padding(18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.06), radius: 10, y: 6)
        )
    }
}
