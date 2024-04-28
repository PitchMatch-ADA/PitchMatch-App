//
//  RecorderDisplay.swift
//  PitchMatch
//
//  Created by Darren Thiores on 27/04/24.
//

import SwiftUI


struct RecorderDisplay: View {
    @State private var scrollPosition: Int? = 0
    
    let backgroundRatios: [Double]
    let powerRatios: [Double]
    let color: Color
    let proxy: GeometryProxy
    
    var height: CGFloat?
    var isLoading: Bool = true
    
    let barWidth = 3.0
    var barCount: Int {
        Int(proxy.size.width / Double(2 * barWidth))
    }
    let defaultLevel = 0.05
    var center: CGFloat {
        if let height = height {
            height / 2
        } else {
            proxy.size.height / 2
        }
    }
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            ZStack {
                HStack(spacing: barWidth) {
                    Spacer()
                        .frame(width: 3)
                    
                    ForEach(
                        Array(
                            backgroundRatios
                                .map { ratio in
                                    min(max(defaultLevel, ratio), 1.0)
                                }
                                .enumerated()
                        ),
                        id: \.offset
                    ) { i, ratio in
                        RoundedRectangle(cornerRadius: 10)
                            .frame(
                                width: barWidth,
                                height: (center - (center - center * ratio)) * 2.0
                            )
                            .foregroundStyle(.gray)
                    }
                    .scrollTargetLayout()
                    
                    Spacer()
                }
                
                HStack(spacing: barWidth) {
                    Spacer()
                        .frame(width: 3)
                    
                    ForEach(
                        Array(
                            powerRatios
                                .map { ratio in
                                    min(max(defaultLevel, ratio), 1.0)
                                }
                                .enumerated()
                        ),
                        id: \.offset
                    ) { i, ratio in
                        RoundedRectangle(cornerRadius: 10)
                            .frame(
                                width: barWidth,
                                height: (center - (center - center * ratio)) * 2.0
                            )
                            .foregroundStyle(color.opacity(0.5))
                    }
                    
                    Spacer()
                }
            }
            .padding(.vertical)
        }
        .frame(height: height)
        .scrollPosition(id: $scrollPosition)
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(color, lineWidth: 1)
        )
        .padding(8)
        .background(.bg)
        .overlay {
            if isLoading {
                ZStack(alignment: .center) {
                    Color.black
                        .opacity(0.4)
                    
                    ProgressView()
                        .tint(color)
                        .controlSize(.large)
                }
            }
        }
        .cornerRadius(10)
        .padding()
        .shadow(radius: 4)
        .onChange(of: powerRatios) { ratio in
            if ratio.count >= (barCount/2) {
                scrollPosition = (scrollPosition ?? 0) + 1
            }
            
            if ratio.count == 0 {
                scrollPosition = 0
            }
        }
    }
}

#Preview {
    GeometryReader { proxy in
        RecorderDisplay(
            backgroundRatios: Song.getAP()[1].powerRatios.map { ratio in
                Double(truncating: ratio as NSNumber)
            },
            powerRatios: Song.getAP()[1].powerRatios.map { ratio in
                Double(truncating: ratio as NSNumber)
            },
            color: .yellowMain,
            proxy: proxy
        )
    }
}
