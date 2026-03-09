import SwiftUI

enum CardCategory: String, CaseIterable, Identifiable, Codable {
    case chaotic
    case evil
    case love
    case playful
    case brave
    case shy
    case funny
    case dramatic
    case suspicious
    case kind
    case rude
    case flirty
    case neutral
    case diverting

    var id: String { rawValue }

    var title: String {
        switch self {
        case .chaotic: return "Chaotic"
        case .evil: return "Evil"
        case .love: return "Love"
        case .playful: return "Playful"
        case .brave: return "Brave"
        case .shy: return "Shy"
        case .funny: return "Funny"
        case .dramatic: return "Dramatic"
        case .suspicious: return "Suspicious"
        case .kind: return "Kind"
        case .rude: return "Rude"
        case .flirty: return "Flirty"
        case .neutral: return "Neutral"
        case .diverting: return "Diverting"
        }
    }

    var systemImage: String {
        switch self {
        case .chaotic: return "sparkles"
        case .evil: return "flame.fill"
        case .love: return "heart.fill"
        case .playful: return "face.smiling"
        case .brave: return "shield.fill"
        case .shy: return "moon.fill"
        case .funny: return "theatermasks.fill"
        case .dramatic: return "bolt.fill"
        case .suspicious: return "eye.fill"
        case .kind: return "hands.sparkles.fill"
        case .rude: return "hand.raised.fill"
        case .flirty: return "heart.circle.fill"
        case .neutral: return "circle.lefthalf.filled"
        case .diverting: return "arrow.triangle.branch"
        }
    }

    var tint: Color {
        switch self {
        case .chaotic: return .purple
        case .evil: return .red
        case .love: return .pink
        case .playful: return .orange
        case .brave: return .blue
        case .shy: return .indigo
        case .funny: return .yellow
        case .dramatic: return .brown
        case .suspicious: return .gray
        case .kind: return .green
        case .rude: return .red
        case .flirty: return .pink
        case .neutral: return .gray
        case .diverting: return .mint
        }
    }
}
