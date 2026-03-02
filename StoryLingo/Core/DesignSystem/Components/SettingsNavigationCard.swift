//
//  SettingsCard.swift
//  StoryLingo
//
//  Created by Jakob Jacobsen on 02/03/2026.
//

import SwiftUI

struct SettingsNavigationCard<Destination: View>: View {
    let title: String
    let value: String
    var leadingValue: String? = nil
    let destination: Destination

    init(
        title: String,
        value: String,
        leadingValue: String? = nil,
        @ViewBuilder destination: () -> Destination
    ) {
        self.title = title
        self.value = value
        self.leadingValue = leadingValue
        self.destination = destination()
    }

    var body: some View {
        NavigationLink {
            destination
        } label: {
            SettingsCard {
                VStack(alignment: .leading, spacing: 12) {
                    Text(title)
                        .font(.system(size: 16))
                        .foregroundStyle(.secondary)

                    HStack(spacing: 10) {
                        if let leadingValue {
                            Text(leadingValue)
                                .font(.system(size: 22))
                        }

                        Text(value)
                            .font(.system(size: 18, weight: .bold))

                        Spacer()

                        Image(systemName: "chevron.right")
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundStyle(.tertiary)
                    }
                }
                .padding(20)
            }
        }
        .buttonStyle(.plain)
    }
}
