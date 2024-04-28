//
//  CircleNav.swift
//  PitchMatch
//
//  Created by Giventus Marco Victorio Handojo on 27/04/24.
//

import SwiftUI

struct CircleNav: View {
    let  iconName:String
    let circleSize:CGFloat
    let iconColor:Color
    let iconSize:CGFloat
    var backgroundColor: Color?
//    let circleSize:Int
    
    var body: some View {
        ZStack {
            Circle()
                .frame(width: circleSize, height: circleSize)
                .foregroundColor(backgroundColor ?? Color.white)
            Image(systemName: iconName)
                .foregroundColor(iconColor)
                .font(.system(size: iconSize))
        }
    }
}

#Preview {
    CircleNav(iconName: "heart.fill", circleSize: 100, iconColor: .red, iconSize: 20)
}
