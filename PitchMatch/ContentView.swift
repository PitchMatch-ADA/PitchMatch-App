//
//  ContentView.swift
//  PitchMatch
//
//  Created by Darren Thiores on 23/04/24.
//

import SwiftUI

struct ContentView: View {
    let model: LyricClassifierModel? = try? LyricClassifierModel(configuration: .init())
    
    var body: some View {
        VStack {
            Image(systemName: "music.note")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("PitchMatch!")
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
