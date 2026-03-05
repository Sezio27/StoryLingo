//
//  Appcontainer.swift
//  StoryLingo
//
//  Created by Jakob Jacobsen on 05/03/2026.
//

import Foundation

final class AppContainer {
    let llmClient: any LLMClient

    init() {
        // DEV: read from Info.plist key "OPENAI_API_KEY"
        // (Set it via a Secrets.xcconfig -> Info.plist substitution, and don't commit it.)
        let key = (Bundle.main.object(forInfoDictionaryKey: "OPENAI_API_KEY") as? String) ?? ""
      
        llmClient = OpenAIClient(config: .init(apiKey: key))
    }
}
