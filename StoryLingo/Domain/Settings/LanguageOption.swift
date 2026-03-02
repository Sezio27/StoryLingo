//
//  LanguageOption.swift
//  StoryLingo
//
//  Created by Jakob Jacobsen on 02/03/2026.
//

import Foundation

struct LanguageOption: Identifiable, Hashable {
    var id: String { code }
    let code: String
    let name: String
    let flag: String
}
