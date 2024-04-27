//
//  CircleButton.swift
//  PitchMatch
//
//  Created by Darren Thiores on 26/04/24.
//

import SwiftUI

struct CircleButton: View {
    let iconName: String
    let onClick: () -> Void
    var logoColor: Color?
    var backgroundColor: Color? //TODO: sumpah aneh banget ini gabisa muncul param nya pas declare
    
    var iconSize: Font = .largeTitle
    var circleSize: CGFloat = 96
    
    var body: some View {
        Button {
            onClick()
        } label: {
            ZStack {
                Image(systemName: iconName)
                    .font(iconSize)
                    .foregroundStyle(logoColor ?? Color.yellowMain)
            }
            .frame(
                width: circleSize,
                height: circleSize
            )
            .background(backgroundColor ?? Color.bg)
            .clipShape(Circle())
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    ZStack {
        CircleButton(
            iconName: "mic.fill",
            onClick: {  }
        )
    }
    .background(.red)
}
