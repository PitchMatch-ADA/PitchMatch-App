//
//  RecordResultView.swift
//  PitchMatch
//
//  Created by Darren Thiores on 28/04/24.
//

import SwiftUI

struct RecordResultView: View {
    let singer: Singer?
    let clip: Song?
    let result: Double
    let waves: [Float]
    let onButtonClick: () -> Void

    var body: some View {
        GeometryReader { proxy in
            VStack {
                Spacer()
                    .frame(height: proxy.size.height / 5)
                
                if let singer = singer {
                    CircularProgressBar(
                        progress: result,
                        singer: singer,
                        barColor: singer.getShadeColor()
                    )
                    .buttonStyle(.plain)
                } else {
                    CircularProgressBar(
                        progress: result,
                        singer: Singer(id: "", imageName: "", clips: []),
                        barColor: singer?.getShadeColor() ?? .yellowShade4
                    )
                    .buttonStyle(.plain)
                }
                
                RecorderDisplay(
                    backgroundRatios: clip?.powerRatios.map { ratio in
                        Double(truncating: ratio as NSNumber)
                    } ?? [],
                    powerRatios: waves.map { ratio in
                        Double(truncating: ratio as NSNumber)
                    },
                    color: singer?.getPrimaryColor() ?? .yellowMain,
                    proxy: proxy,
                    height: 64,
                    isLoading: false
                )
                
                Spacer()
                    .frame(height: 24)
                
                CircleButton(
                    iconName: "house.fill",
                    onClick: onButtonClick,
                    logoColor: singer?.getPrimaryColor()
                )
                
                Spacer()
            }
        }
        .padding()
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
    RecordResultView(
        singer: Singer.getSingers()[0],
        clip: Song.getAP()[0],
        result: 50,
        waves: [],
        onButtonClick: {  }
    )
}
