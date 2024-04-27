//
//  RecordView.swift
//  PitchMatch
//
//  Created by Darren Thiores on 26/04/24.
//

import SwiftUI

struct RecordView: View {
    let singer: Singer?
    
    private var clip: Song? {
        singer?.getRandomClip()
    }
    
    var body: some View {
        VStack {
            Image(singer?.imageName ?? "")
                .resizable()
                .scaledToFill()
                .frame(width: 120, height: 120)
                .clipShape(Circle())
                .clipped()
            
            Spacer()
            
            HStack {
                Spacer()
            }
            
            Spacer()
            
            CircleButton(
                iconName: "mic.fill",
                onClick: {  }
            )
        }
        .padding(.vertical, 64)
        .background(
            LinearGradient(
                colors: [
                    singer?.getShadeColor() ?? .yellowShade4,
                    singer?.getTintColor() ?? .yellowTint4,
                    singer?.getShadeColor() ?? .yellowShade4
                ],
                startPoint: .top,
                endPoint: .bottom
            )
        )
    }
}

#Preview {
    RecordView(
        singer: Singer.getSingers()[0]
    )
}
