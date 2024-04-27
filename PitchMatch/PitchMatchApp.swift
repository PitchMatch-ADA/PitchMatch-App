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
//                .task {
//                    guard let path = Bundle.main.path(forResource: "TulusTemanHidup", ofType:"mp3") else {
//                        fatalError("Couldn't find the file path")
//                    }
//                    let url = URL(fileURLWithPath: path)
//                    var outputArray : [Float] = []
//                    let targetSamples = 24 * 20
//                    
//                    AudioContext.load(fromAudioURL: url, completionHandler: { audioContext in
//                        guard let audioContext = audioContext else {
//                            fatalError("Couldn't create the audioContext")
//                        }
//                        outputArray = render(audioContext: audioContext, targetSamples: targetSamples)
//                        let newArray = outputArray.map { powerOffset in
//                            if powerOffset < -50 {
//                                Float(0.0)
//                            } else {
//                                Float((50 + powerOffset) / 50)
//                            }
//                        }
//                        
//                        print(outputArray)
//                        print(newArray)
//                    })
//                }
        }
        .modelContainer(for: [History.self])
    }
}
