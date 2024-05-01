//
//  LyricClassifier.swift
//  PitchMatch
//
//  Created by Darren Thiores on 29/04/24.
//

import Foundation
import NaturalLanguage
import CoreML

class LyricClassifier {
    static let lyricClassifierModel: FinalLyricClassifier? = try? FinalLyricClassifier(
        configuration: MLModelConfiguration()
    )
    
    private init() {  }
    
    static func predict(lyric: String) -> Double {
        guard let model = LyricClassifier.lyricClassifierModel?.model else {
            print("Model null")
            return 0
        }
        guard let classifier = try? NLModel(mlModel: model) else {
            print("NL Model null")
            return 0
        }
        
        let prediction = classifier.predictedLabel(for: lyric)
        let predictionSet = classifier.predictedLabelHypotheses(for: lyric, maximumCount: 1)
        let confidence = predictionSet[prediction ?? ""] ?? 0.0
    
        return confidence
    }
}
