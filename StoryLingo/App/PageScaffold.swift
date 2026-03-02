import SwiftUI

struct PageScaffold<Content: View>: View {
    let title: String
    let subtitle: LocalizedStringKey
    let contentHorizontalPadding: CGFloat
    let scrolls: Bool
    let showsBackButton: Bool
    @ViewBuilder var content: Content

    init(
        title: String,
        subtitle: LocalizedStringKey,
        contentHorizontalPadding: CGFloat = 20,
        scrolls: Bool = false,
        showsBackButton: Bool = false,
        @ViewBuilder content: () -> Content
    ) {
        self.title = title
        self.subtitle = subtitle
        self.contentHorizontalPadding = contentHorizontalPadding
        self.scrolls = scrolls
        self.showsBackButton = showsBackButton
        self.content = content()
    }

    var body: some View {
        ZStack {
            Color(.systemGroupedBackground).ignoresSafeArea()

            VStack(alignment: .leading, spacing: 16) {
                PageHeader(title: title, subtitle: subtitle, showsBackButton: showsBackButton)

                if scrolls {
                    ScrollView { contentBody.padding(.bottom, 24) }
                } else {
                    contentBody.frame(maxHeight: .infinity, alignment: .top)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(showsBackButton)   // ✅ hide system back button
    }

    private var contentBody: some View {
        content
            .padding(.horizontal, contentHorizontalPadding)
            .frame(maxWidth: .infinity, alignment: .leading)
    }
}
