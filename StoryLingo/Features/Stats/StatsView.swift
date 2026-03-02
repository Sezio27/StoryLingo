//
//  StatsView.swift
//  StoryLingo
//
//  Created by Jakob Jacobsen on 12/02/2026.
//

import SwiftUI

struct StatsView: View {
    
    var body: some View {
        PageScaffold(
                    title: "Statistics",
                    subtitle: "Track your learning progress",
                    scrolls: true
        ) {
                
                VStack(spacing: 16) {
                  
                    Text("Current Progress")
                    HStack(spacing: 18) {
                        StatCardNumber(
                            icon: "sparkles",
                            title: "Unique Words",
                            amount: "127"
                        )
                        StatCardNumber(
                            icon: "sparkles",
                            title: "Practice Time",
                            amount: "240 min"
                        )
                        
                    }.frame(maxWidth: .infinity, alignment: .center)
                    
                    Text("Goals")
                    
                    VStack(spacing: 14 ) {
                        let currentWords = 127
                        let goalWords = 500
                        let remaining = goalWords - currentWords
                        let p = Double(currentWords) / Double(goalWords)
                        GoalProgressCard(
                            icon: "bubble.left",
                            iconTint: .blue,
                            iconBackground: .blue.opacity(0.10),
                            title: "Vocabulary Goal",
                            subtitle: "Learn 500 unique words in French",
                            value: "\(currentWords) / \(goalWords)",
                            progress: p,
                            footer: "\(Int(p * 100))% complete • ^[\(remaining) word](inflect: true) to go"
                        )
                        
                        let practicedMinutes = 240          // 4h 0m
                        let goalMinutes = 600               // 10h
                        let remainingMinutes = max(0, goalMinutes - practicedMinutes)
                        let progress = Double(practicedMinutes) / Double(goalMinutes)
                        
                        GoalProgressCard(
                            icon: "clock",
                            iconTint: .cyan,
                            iconBackground: .cyan.opacity(0.12),
                            title: "Practice Time Goal",
                            subtitle: "Reach 10 hours of practice time",
                            value: "4h 0m / 10h",
                            progress: progress,
                            footer: "\(Int(progress * 100))% complete • 6h 0m to go",
                            progressTint: .cyan
                        )
                        
                    }
                    
                    Text("Overall Statistics")
                    StatsListCard(items: [
                        .init(icon: "target", iconTint: .green, iconBackground: .green.opacity(0.12),
                              title: "Stories Completed", value: "3"),
                        .init(icon: "bubble.left", iconTint: .gray, iconBackground: .orange.opacity(0.12),
                              title: "Total Messages", value: "156"),
                        .init(icon: "sparkles", iconTint: .orange, iconBackground: .pink.opacity(0.12),
                              title: "Corrections Learned", value: "18"),
                        .init(icon: "chart.line.uptrend.xyaxis", iconTint: .red, iconBackground: .blue.opacity(0.12),
                              title: "Current Streak", value: "12 days")
                    ])
                    
                }

                  
            }
            
            
        

    }
}
