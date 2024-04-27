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
    @Attribute(.unique) let id: UUID = UUID()
    var singerId: String
    var powerRatios: [Float]
    var frequencies: [Float]
    var songId: String
    var overallScore: Float
    
    init(singerId: String, powerRatios: [Float], frequencies: [Float], songId: String, overallScore: Float) {
        self.singerId = singerId
        self.powerRatios = powerRatios
        self.frequencies = frequencies
        self.songId = songId
        self.overallScore = overallScore
    }
    
}
