//
//  TranslationDTO.swift
//  StoryLingo
//
//  Created by Jakob Jacobsen on 06/03/2026.
//

struct TranslationDTO: Decodable {
    let translatedText: String
    let detectedSourceLanguageCode: String?
    let targetLanguageCode: String
}
