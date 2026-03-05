import SwiftUI

struct EmptyStoriesView: View {
    let onCreateNewStory: () -> Void

    var body: some View {
        VStack(spacing: 14) {
            Image(systemName: "books.vertical")
                .font(.system(size: 34, weight: .semibold))
                .foregroundStyle(.secondary)

            Text("No stories yet")
                .font(.system(size: 20, weight: .bold, design: .rounded))

            Text("Create a new story and it will show up here.")
                .font(.system(size: 14, design: .rounded))
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 16)

            Spacer(minLength: 6)

            NewStoryButton(title: "Create New Story", systemImage: "wand.and.stars") {
                onCreateNewStory()
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 26)
        .padding(.horizontal, 22)
    }
}
