//
//  BubbleTranslation.swift
//  StoryLingo
//
//  Created by Jakob Jacobsen on 06/03/2026.
//

import Foundation
import CoreData

struct BubbleTranslation: Equatable {
    let messageID: NSManagedObjectID
    let targetLanguageCode: String
    let targetLanguageFlag: String
    let text: String
}
