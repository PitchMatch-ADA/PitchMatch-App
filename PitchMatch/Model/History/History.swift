//
//  History.swift
//  PitchMatch
//
//  Created by Darren Thiores on 26/04/24.
//

import Foundation
import SwiftData

@Model
class History: Identifiable {
    @Attribute(.unique) let id: String
    var singerId: String
    var powerRatios: String
    var frequencies: String
    var songId: String
    var overallScore: Double
    
    init(id: String, singerId: String, powerRatios: String, frequencies: String, songId: String, overallScore: Double) {
        self.id = id
        self.singerId = singerId
        self.powerRatios = powerRatios
        self.frequencies = frequencies
        self.songId = songId
        self.overallScore = overallScore
    }
    
    func delete(context: ModelContext) {
        context.delete(self)
    }
    
    func insert(context: ModelContext) {
        context.insert(self)
    }
    
    func processPowerFloatArrayString() -> [Float] {
        return powerRatios
            .components(separatedBy: ",")
            .compactMap { ratio in
                try? Float(ratio)
            }
    }
    
    func processFrequenciesFloatArrayString() -> [Float] {
        return frequencies
            .components(separatedBy: ",")
            .compactMap { ratio in
                try? Float(ratio)
            }
    }
    
    static func processFloatArrayToString(array: [Float]) -> String {
        var arrayString = "\(array)"
        
        guard let firstChar = arrayString
            .first else {
            return ""
        }
        
        guard let lastChar = arrayString
            .last else {
            return ""
        }
        
        if String(firstChar) == "[" {
            arrayString.removeFirst()
        }
        
        if String(lastChar) == "]" {
            arrayString.removeLast()
        }
        
        arrayString.replace(" ", with: "")
        
        return arrayString
    }
}
