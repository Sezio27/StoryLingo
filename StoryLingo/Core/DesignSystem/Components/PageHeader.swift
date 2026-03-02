//
//  FeatureRow.swift
//  StoryLingo
//
//  Created by Jakob Jacobsen on 12/02/2026.
//

import SwiftUI

struct PageHeader: View {
    let title: String
    let subtitle: LocalizedStringKey
    
    var body: some View {
        
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.system(size: 38, weight: .bold, design: .rounded))
            
            Text(subtitle)
                .font(.system(size: 18))
                .foregroundStyle(.secondary)
        }
        .padding(.horizontal, 22)
        .padding(.top, 18)
        
    }
}
