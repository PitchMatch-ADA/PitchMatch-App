//
//  SingerExtension.swift
//  PitchMatch
//
//  Created by Darren Thiores on 26/04/24.
//

import Foundation
import SwiftUI

extension Singer {
    func getPrimaryColor() -> Color {
        switch self.id {
        case "ArdhitoPramono":
            return .purpleMain
        case "Tulus":
            return .yellowMain
        case "Ran":
            return .redMain
        default:
            return .yellowMain
        }
    }
    
    func getTintColor() -> Color {
        switch self.id {
        case "ArdhitoPramono":
            return .purpleTint4
        case "Tulus":
            return .yellowTint4
        case "Ran":
            return .redTint4
        default:
            return .yellowTint4
        }
    }
    
    func getShadeColor() -> Color {
        switch self.id {
        case "ArdhitoPramono":
            return .purpleShade1
        case "Tulus":
            return .yellowShade1
        case "Ran":
            return .redShade1
        default:
            return .yellowShade1
        }
    }
    
    func getShadeThreeColor() -> Color {
        switch self.id {
        case "ArdhitoPramono":
            return .purpleShade3
        case "Tulus":
            return .yellowShade3
        case "Ran":
            return .redShade3
        default:
            return .yellowShade3
        }
    }
    
    func getInteractiveColor() -> Color {
        switch self.id {
        case "ArdhitoPramono":
            return .purpleShade3
        case "Tulus":
            return .yellowShade3
        case "Ran":
            return .redShade3
        default:
            return .yellowShade3
        }
    }
}
