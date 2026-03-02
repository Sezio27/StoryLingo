//
//  SettingsTableCard.swift
//  StoryLingo
//
//  Created by Jakob Jacobsen on 02/03/2026.
//
import SwiftUI

struct SettingsTableCard: View {
    let rows: [(String, String)]

    var body: some View {
        SettingsCard {
            VStack(spacing: 0) {
                ForEach(rows.indices, id: \.self) { i in
                    let row = rows[i]

                    HStack {
                        Text(row.0)
                            .foregroundStyle(.secondary)
                        Spacer()
                        Text(row.1)
                            .font(.system(size: 22, weight: .bold))
                    }
                    .padding(.vertical, 18)
                    .padding(.horizontal, 20)

                    if i != rows.indices.last {
                        Divider()
                            .padding(.leading, 20)
                    }
                }
            }
        }
        .padding(.top, 6)
    }
}
