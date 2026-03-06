//
//  StoryLingoApp.swift
//  StoryLingo
//
//  Created by Jakob Jacobsen on 12/02/2026.
//

import SwiftUI
import CoreData

@main
struct StoryLingoApp: App {
    private let appContainer = AppContainer()
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
                .environment(\.llmClient, appContainer.llmClient)
                .environment(\.speechSynthesizer, appContainer.speechSynthesizer)
                .environment(\.speechRecognizerService, appContainer.speechRecognizerService)
        }
    }
}
