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
    
    init(singerId: String) {
        self.singerId = singerId
    }
}
