import SwiftUI
import CoreData

struct HomeView: View {
    @ObservedObject var settings: AppSettings
    @Environment(\.managedObjectContext) private var ctx
    @Environment(\.llmClient) private var llmClient
    @State private var goToCreateStory = false
    @State private var goToChat = false
        @State private var activeStory: Story?

    var body: some View {
    
            ScrollView {
                VStack(spacing: 22) {
                    
               
                                       NavigationLink(isActive: $goToCreateStory) {
                                           CreateStoryView(settings: settings) { story in
                                               activeStory = story
                                               goToChat = true
                                           }
                                       } label: { EmptyView() }
                                       .hidden()
                    
                    // Push Chat (after CreateStory dismissed)
                                       NavigationLink(isActive: $goToChat) {
                                           if let story = activeStory {
                                               ChatView(
                                                   vm: ChatViewModel(
                                                       story: story,
                                                       repo: CoreDataChatRepository(ctx: ctx),
                                                       llm: llmClient
                                                   )
                                               )
                                           }
                                       } label: { EmptyView() }
                                       .hidden()

                    // Quick dev button
                    Button {
                        settings.hasCompletedOnboarding = false
                        settings.updatedAt = Date()
                        ctx.saveIfNeeded()
                    } label: {
                        Label("Onboarding", systemImage: "arrow.counterclockwise")
                            .font(.system(size: 14, weight: .semibold))
                            .padding(.horizontal, 12)
                            .padding(.vertical, 10)
                            .background(
                                RoundedRectangle(cornerRadius: 12, style: .continuous)
                                    .fill(Color(.systemBackground))
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 12, style: .continuous)
                                    .stroke(Color.black.opacity(0.06), lineWidth: 1)
                            )
                    }
                    .buttonStyle(.plain)
                    .frame(maxWidth: .infinity, alignment: .trailing)
                    .padding(.horizontal, 20)
                    .padding(.top, 12)

                    GlassIconTile(emoji: "📜", size: 110)
                        .padding(.top, 16)

                    VStack(spacing: 16) {
                        Text("StoryLingo")
                            .font(.system(size: 32, weight: .bold, design: .rounded))

                        Text("Create stories with AI and practice your\nlanguage skills")
                            .font(.system(size: 16, weight: .regular))
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                            .lineSpacing(3)
                    }
                    .padding(.top, 20)

                    NewStoryButton(title: "Create New Story", systemImage: "wand.and.stars") {
                        goToCreateStory = true
                    }
                    .padding(.horizontal, 30)
                    .padding(.top, 14)

                    VStack(spacing: 22) {
                        FeatureRow(
                            icon: "sparkles",
                            iconBackground: Color.blue.opacity(0.12),
                            title: "AI-Powered Learning",
                            subtitle: "Interactive conversations tailored to your level"
                        )

                        FeatureRow(
                            icon: "mic",
                            iconBackground: Color.gray.opacity(0.12),
                            title: "Voice & Text",
                            subtitle: "Practice speaking and writing naturally"
                        )

                        FeatureRow(
                            icon: "wand.and.stars",
                            iconBackground: Color.yellow.opacity(0.12),
                            title: "Gentle Corrections",
                            subtitle: "Learn from your mistakes in real-time"
                        )
                    }
                    .padding(.horizontal, 30)
                    .padding(.top, 20)

                    Spacer(minLength: 22)
                }
            }
            .background(Color(.systemGroupedBackground))
            .navigationBarTitleDisplayMode(.inline)
        }
    }

