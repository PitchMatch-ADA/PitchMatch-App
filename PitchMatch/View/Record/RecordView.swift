//
//  RecordView.swift
//  PitchMatch
//
//  Created by Darren Thiores on 26/04/24.
//

import SwiftUI
import AVFoundation

struct RecordView: View {
    @EnvironmentObject private var voiceToTextParser: VoiceToTextParser
    let singer: Singer?
    
    @State private var clip: Song? = nil
    @State private var audioPlayer: AVAudioPlayer? = nil
    
    @State private var timer = Timer.publish(every: 0.05, on: .main, in: .common).autoconnect()
    @State private var songPowerRatios: [Float] = []
    @State private var receiveTime = 0
    
    @State private var isLoading: Bool = true
    @State private var finishFirstTime: Bool = false
    @State private var isPlaying: Bool = false
    
    var body: some View {
        GeometryReader { proxy in
            VStack {
                Image(singer?.imageName ?? "")
                    .resizable()
                    .scaledToFill()
                    .frame(width: 120, height: 120)
                    .clipShape(Circle())
                    .clipped()
                
                Spacer()
                
                RecorderDisplay(
                    backgroundRatios: clip?.powerRatios.map { ratio in
                        Double(truncating: ratio as NSNumber)
                    } ?? [],
                    powerRatios: songPowerRatios.map { ratio in
                        Double(truncating: ratio as NSNumber)
                    },
                    color: singer?.getPrimaryColor() ?? .yellowMain,
                    proxy: proxy,
                    height: 300,
                    isLoading: isLoading
                )
                
                Spacer()
                
                HStack {
                    if finishFirstTime {
                        let disabled = isPlaying
                        
                        CircleButton(
                            iconName: "arrow.circlepath",
                            onClick: {
                                songPowerRatios = []
                                timer = Timer.publish(every: 0.05, on: .main, in: .common).autoconnect()
                                receiveTime = 0
                                
                                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                    audioPlayer?.play()
                                    isPlaying = true
                                }
                            },
                            logoColor: disabled ? .gray : singer?.getPrimaryColor(),
                            iconSize: .headline,
                            circleSize: 64
                        )
                        .disabled(disabled)
                    } else {
                        Spacer()
                            .frame(width: 64)
                    }
                    
                    Spacer()
                    
                    let disabled = !finishFirstTime || isPlaying
                    
                    CircleButton(
                        iconName: "mic.fill",
                        onClick: {
                            
                        },
                        logoColor: disabled ? .gray : singer?.getPrimaryColor()
                    )
                    .disabled(disabled)
                    
                    Spacer()
                    
                    Spacer()
                        .frame(width: 64)
                }
                .padding(.horizontal, 24)
            }
        }
        .padding(.vertical, 48)
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
        .onAppear {
            let randomClip = singer?.getRandomClip()
            clip = randomClip
        }
        .onDisappear {
            audioPlayer?.stop()
        }
        .task {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                if let fileName = Bundle.main.path(forResource: clip?.id, ofType: "mp3") {
                    audioPlayer = try? AVAudioPlayer(contentsOf: URL(fileURLWithPath: fileName))
                }
                
                do {
                    try AVAudioSession.sharedInstance().setCategory(.playback)
                } catch(let error) {
                    print(error.localizedDescription)
                }
                
                isLoading = false
                audioPlayer?.play()
                isPlaying = true
            }
        }
        .onReceive(timer) { _ in
            if audioPlayer?.isPlaying ?? false || !songPowerRatios.isEmpty {
                print(receiveTime)
                
                songPowerRatios.append(clip?.powerRatios[receiveTime] ?? 0.0)
                receiveTime += 1
                
                if (receiveTime/20) == clip?.second {
                    timer.upstream.connect().cancel()
                    isPlaying = false
                    finishFirstTime = true
                }
            }
        }
    }
}

#Preview {
    RecordView(
        singer: Singer.getSingers()[2]
    )
    .environmentObject(VoiceToTextParser())
}
