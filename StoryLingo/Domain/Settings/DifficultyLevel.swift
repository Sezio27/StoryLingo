//
//  DifficultyLevel.swift
//  StoryLingo
//
//  Created by Jakob Jacobsen on 02/03/2026.
//

import Foundation

enum DifficultyLevel: Int16, CaseIterable, Identifiable {
    case beginner = 0
    case intermediate = 1
    case advanced = 2

    var id: Int16 { rawValue }

    var title: String {
        switch self {
        case .beginner: return "Beginner"
        case .intermediate: return "Intermediate"
        case .advanced: return "Advanced"
        }
    }
}
