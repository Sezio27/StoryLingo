import Foundation

enum MockReplyCardFactory {
    static func makeHand() -> [ReplyCardItem] {
        let categories = Array(CardCategory.allCases.shuffled().prefix(3))

        return categories.map { category in
            let pair = sampleText(for: category)

            return ReplyCardItem(
                kind: .category,
                category: category,
                text: pair.danish,
                translationText: pair.english
            )
        }
    }

    private static func sampleText(for category: CardCategory) -> (danish: String, english: String) {
        switch category {
        case .chaotic:
            return (
                "Jeg troede, det her var et bageri.",
                "I thought this was a bakery."
            )
        case .evil:
            return (
                "Jeg kom for at tage kronen.",
                "I came to take the crown."
            )
        case .love:
            return (
                "Jeg fulgte mit hjerte hertil.",
                "I followed my heart here."
            )
        case .playful:
            return (
                "Måske er jeg her for at lave ballade.",
                "Maybe I am here for trouble."
            )
        case .brave:
            return (
                "Jeg er ikke bange.",
                "I am not afraid."
            )
        case .shy:
            return (
                "Jeg ville bare kigge mig omkring.",
                "I just wanted to look around."
            )
        case .funny:
            return (
                "Jeg er her for snacks og eventyr.",
                "I am here for snacks and adventure."
            )
        case .dramatic:
            return (
                "Min skæbne førte mig hertil.",
                "My fate brought me here."
            )
        case .suspicious:
            return (
                "Det kommer an på, hvem der spørger.",
                "That depends on who is asking."
            )
        case .kind:
            return (
                "Jeg vil bare gerne hjælpe.",
                "I only want to help."
            )
        case .rude:
            return (
                "Det rager ikke dig.",
                "That is none of your business."
            )
        case .flirty:
            return (
                "Måske kom jeg for at se dig.",
                "Maybe I came here to see you."
            )
        case .neutral:
            return (
                "Jeg er bare på gennemrejse.",
                "I am just passing through."
            )
        case .diverting:
            return (
                "Kan vi tale om noget andet?",
                "Can we talk about something else?"
            )
        }
    }
}
