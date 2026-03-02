//
//  FeatureRow.swift
//  StoryLingo
//
//  Created by Jakob Jacobsen on 12/02/2026.
//

import SwiftUI

struct StatCardNumber: View {
    let icon: String
    let title: String
    let amount: String

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 10){
                Text(title)
                    .font(.system(size: 14))
                    .foregroundStyle(.secondary)

                Image(systemName: icon)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(.blue)
            }
            
            Text(amount)
                .font(.system(size: 20, weight: .semibold))

        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.06), radius: 10, y: 6)
       
              
        )
        
    }
}

#Preview {
    StatCardNumber(
        icon: "sparkles",
        title: "Unique Words",
        amount: "127"
    )
    .padding()
}
