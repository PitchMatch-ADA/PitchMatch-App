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
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: [History.self])
    }
}
