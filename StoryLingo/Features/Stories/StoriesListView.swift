//
//  StoriesListView.swift
//  StoryLingo
//
//  Created by Jakob Jacobsen on 14/02/2026.
//

import SwiftUI

struct StoriesListView: View {
    // Mock data for now (replace with Core Data later)
    private let stories: [MockStory] = [
        .init(title: "A Trip to the Market", relativeTime: "2 hours ago", messageCount: 24),
        .init(title: "Meeting New Friends", relativeTime: "Yesterday", messageCount: 18),
        .init(title: "At the Restaurant", relativeTime: "3 days ago", messageCount: 32)
    ]

    var body: some View {
        PageScaffold(
                    title: "My Stories",
                    subtitle: "^[\(stories.count) story](inflect: true)"
        ) {

                    VStack(spacing: 16) {
                        ForEach(stories) { story in
                            
                            NavigationLink {
                                StoryDetailView(
                                    title: story.title,
                                    relativeTime: story.relativeTime,
                                    messageCount: story.messageCount
                                )
                            } label: {
                                StoryCardRow(
                                    title: story.title,
                                    relativeTime: story.relativeTime,
                                    messageCount: story.messageCount
                                )
                            } .buttonStyle(.plain)                 
                                .foregroundStyle(.primary)
                            
                           
                        }
                    }
                   
                    .padding(.top, 6)

                    Spacer(minLength: 24)
                }
            }
            

    
}

private struct MockStory: Identifiable {
    let id = UUID()
    let title: String
    let relativeTime: String
    let messageCount: Int
}

