import SwiftUI
import CoreData

struct StoriesListView: View {
    @ObservedObject var settings: AppSettings
    private let ctx: NSManagedObjectContext
    @StateObject private var vm: StoriesListViewModel
    @Environment(\.llmClient) private var llmClient
    @State private var goToCreateStory = false
    @State private var goToChat = false
    @State private var activeStory: Story?

    init(settings: AppSettings, ctx: NSManagedObjectContext) {
        self.settings = settings
        self.ctx = ctx
        _vm = StateObject(
            wrappedValue: StoriesListViewModel(
                repo: CoreDataStoriesRepository(ctx: ctx),
                ctx: ctx
            )
        )
    }

    var body: some View {
        PageScaffold(
            title: "My Stories",
            subtitle: subtitle,
            scrolls: true
        ) {
            // push create story
            NavigationLink(isActive: $goToCreateStory) {
                CreateStoryView(settings: settings) { story in
                    activeStory = story
                    goToChat = true
                }
            } label: { EmptyView() }
            .hidden()

            // push chat
            NavigationLink(isActive: $goToChat) {
                if let story = activeStory {
                    ChatView(vm: ChatViewModel(story: story, repo: CoreDataChatRepository(ctx: ctx), llm: llmClient))
                }
            } label: { EmptyView() }
            .hidden()

            content
                .padding(.top, 6)
        }
        .task { await vm.load() }
    }

    private var subtitle: LocalizedStringKey {
        switch vm.state {
        case .loaded:
            return "^[\(vm.stories.count) story](inflect: true)"
        default:
            return "Your saved stories"
        }
    }

    @ViewBuilder
    private var content: some View {
        switch vm.state {
        case .loading:
            ProgressView().padding(.top, 20)

        case .empty:
            EmptyStoriesView {
                goToCreateStory = true
            }

        case .error(let msg):
            VStack(spacing: 12) {
                Text("Couldn’t load stories").font(.headline)
                Text(msg).foregroundStyle(.secondary).multilineTextAlignment(.center)
                Button("Try again") { Task { await vm.load() } }
            }
            .padding(.top, 24)

        case .loaded:
            VStack(spacing: 16) {
                ForEach(vm.stories, id: \.objectID) { story in
                    NavigationLink {
                        StoryDetailView(story: story, ctx: ctx)
                    } label: {
                        StoryCardRow(
                            title: vm.titleText(for: story),
                            relativeTime: vm.relativeTimeText(for: story),
                            messageCount: vm.messageCount(for: story)
                        )
                    }
                    .buttonStyle(.plain)
                    .foregroundStyle(.primary)
                    .contextMenu {
                        Button(role: .destructive) {
                            Task { await vm.delete(story) }
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                    }
                }
            }
        }
    }
}
