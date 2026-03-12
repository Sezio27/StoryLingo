import Foundation

struct ReplyCardsDTO: Decodable {
    let cards: [ReplyCardDTO]
}

struct ReplyCardDTO: Decodable {
    let category: CardCategory
    let replyText: String
    let translatedText: String
}
