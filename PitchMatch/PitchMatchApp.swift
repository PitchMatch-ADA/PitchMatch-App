//
//  PitchMatchApp.swift
//  PitchMatch
//
//  Created by Darren Thiores on 23/04/24.
//

import SwiftUI
import SwiftData

@main
struct PitchMatchApp: App {
    @StateObject private var voiceToTextParser = VoiceToTextParser()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(voiceToTextParser)
        }
        .modelContainer(for: [History.self])
    }
}
