//
//  RecorderDisplay.swift
//  PitchMatch
//
//  Created by Darren Thiores on 27/04/24.
//

import SwiftUI


struct RecorderDisplay: View {
    let backgroundRatios: [Double]
    let powerRatios: [Double]
    let color: Color
    
    var body: some View {
        Canvas { context, size in
            context.clip(
                to: Path(
                    CGRect(
                        origin: .zero,
                        size: size
                    )
                )
            )
            
            let barWidth = 3.0
            let barCount = Int(size.width / Double(2 * barWidth))
            let defaultLevel = 0.05
            
            let startIndex = max(0, (powerRatios.count - barCount))
            let endIndex = min(
                backgroundRatios.count,
                max(
                    barCount,
                    (powerRatios.count + barCount / 2)
                )
            )
            let reversedBgRatios = backgroundRatios
                .map { ratio in
                    min(max(defaultLevel, ratio), 1.0)
                }[startIndex..<endIndex]
                .reversed()
            let reversedRatios = powerRatios
                .map { ratio in
                    min(max(defaultLevel, ratio), 1.0)
                }
                .suffix(barCount)
                .reversed()
            
            for (i, powerRatio) in reversedBgRatios.enumerated() {
                let centerY = CGFloat(size.height / 2.0)
                let yTopStart = CGFloat(centerY - centerY * powerRatio)
                var path = Path()
                
                path.addRoundedRect(
                    in: CGRect(
                        x: CGFloat(size.width) - CGFloat(i) * 2.0 * barWidth,
                        y: yTopStart,
                        width: barWidth,
                        height: (centerY - yTopStart) * 2.0
                    ),
                    cornerSize: CGSize(
                        width: 10.0,
                        height: 10.0
                    )
                )
                
                context.fill(
                    path,
                    with: .color(.gray)
                )
            }
            
            for (i, powerRatio) in reversedRatios.enumerated() {
                let centerY = CGFloat(size.height / 2.0)
                let yTopStart = CGFloat(centerY - centerY * powerRatio)
                var path = Path()
                
                path.addRoundedRect(
                    in: CGRect(
                        x: CGFloat(size.width) - CGFloat(i) * 2.0 * barWidth,
                        y: yTopStart,
                        width: barWidth,
                        height: (centerY - yTopStart) * 2.0
                    ),
                    cornerSize: CGSize(
                        width: 10.0,
                        height: 10.0
                    )
                )
                
                context.fill(
                    path,
                    with: .color(color.opacity(0.5))
                )
            }
        }
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(color, lineWidth: 1)
        )
        .padding(8)
        .background(.bg)
        .cornerRadius(10)
        .padding()
        .shadow(radius: 4)
    }
}

#Preview {
    RecorderDisplay(
        backgroundRatios: Song.getAP()[1].powerRatios.map { ratio in
            Double(truncating: ratio as NSNumber)
        },
        powerRatios: Song.getAP()[0].powerRatios.map { ratio in
            Double(truncating: ratio as NSNumber)
        },
        color: .yellowMain
    )
}
