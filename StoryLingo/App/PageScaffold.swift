//
//  MainTabView.swift
//  StoryLingo
//
//  Created by Jakob Jacobsen on 12/02/2026.
//

import SwiftUI

struct PageScaffold<Content: View>: View {
    let title: String
    let subtitle: LocalizedStringKey
    let contentHorizontalPadding: CGFloat
    @ViewBuilder var content: Content

    init(
        title: String,
        subtitle: LocalizedStringKey,
        contentHorizontalPadding: CGFloat = 20,
        @ViewBuilder content: () -> Content
    ) {
        self.title = title
        self.subtitle = subtitle
        self.contentHorizontalPadding = contentHorizontalPadding
        self.content = content()
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color(.systemGroupedBackground).ignoresSafeArea()

                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        PageHeader(title: title, subtitle: subtitle)
                            .padding(.horizontal, 4)
                            .padding(.top, 4)

                        content
                            .padding(.horizontal, contentHorizontalPadding)
                           

                        Spacer(minLength: 24)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

