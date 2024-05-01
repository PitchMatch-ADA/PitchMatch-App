//
//  HomeView.swift
//  PitchMatch
//
//  Created by Darren Thiores on 26/04/24.
//

import SwiftUI
import AVFAudio
import AVFoundation
import SwiftData

struct HomeView: View {
    @State private var singers: [Singer] = []
    @State private var currentSinger: Singer?
    @State private var selectedIndex: Int = 0
    @State private var haveAppeared: Bool = false
    @State var currentSong: Song? = nil
    
    @Query private var histories: [History]
    @EnvironmentObject private var audioHandler: AudioHandler
    
    private var overallScore : [String: Double] {
        var historyDictionary: [String: [Double]] = Dictionary(
            uniqueKeysWithValues: singers.map { singer in
                (singer.id, [])
            }
        )
        
        histories.forEach { history in
            var lastHistory = historyDictionary[history.singerId]
            
            lastHistory?.append(history.overallScore)
            
            if let newOvScores = lastHistory {
                historyDictionary.updateValue(newOvScores, forKey: history.singerId)
            }
        }
        
        return Dictionary(
            uniqueKeysWithValues:
                historyDictionary.map { key, value in 
                    let ovScore = (value.count > 0) ? value.reduce(0, +) / Double(value.count) : 0.0
                    
                    return (key, ovScore)
                }
        )
    }
    
    var body: some View {
        NavigationStack {
            GeometryReader { proxy in
                let imageWidth = proxy.size.width * 0.65
                let imageHeight = imageWidth + (imageWidth / 2)
                
                VStack {
                    Spacer()
                    
                    TabView(selection: $selectedIndex) {
                        ForEach(
                            Array(singers.enumerated()),
                            id: \.offset
                        ) { index, singer in
                            var offset: CGFloat {
                                if index < selectedIndex {
                                    return imageWidth
                                }
                                
                                if index > selectedIndex {
                                    return -imageWidth
                                }
                                
                                return 0
                            }
                            
                            VStack {
                                
                                
                                CircularProgressBar(progress: overallScore[singer.id] ?? 0.0, singer: Singer(id: singer.id, imageName: singer.imageName, clips: singer.clips), barColor: currentSinger?.getShadeColor() ?? .yellowShade4)
                                    .buttonStyle(.plain)
                                
                                    .padding(.top,30)
                            }
                        }
                        
                    }
                    .frame(
                        height: imageHeight + 64
                    )
                    .tabViewStyle(PageTabViewStyle(indexDisplayMode: .always))
                    .indexViewStyle(PageIndexViewStyle(backgroundDisplayMode: .always))
                    .onChange(of: selectedIndex) { index in
                        currentSinger = singers.isEmpty ? nil : singers[index]
                    }
                    Spacer()
                    HStack{
                        
                        Spacer()
                        NavigationLink{
                            HistoryDetailView(singer: currentSinger)
                        }label: {
                            
                            CircleNav(iconName: "clock.arrow.circlepath", circleSize: 70, iconColor: currentSinger?.getShadeColor() ?? .yellowShade4, iconSize: 30)
                        }
                        
                        Spacer()
                        NavigationLink{
                            
                            RecordView(singer: currentSinger)
                        }label: {
                            CircleNav(iconName: "play.fill", circleSize: 100, iconColor: currentSinger?.getShadeColor() ?? .yellowShade4, iconSize: 50)
                        }
                        .padding(.trailing,65)
                        Spacer()
                        Spacer()
                    }
                    Spacer()
                    Spacer()
                    Spacer()
                }
            }
            .background(
                LinearGradient(gradient: Gradient(colors: [currentSinger?.getShadeColor() ?? .yellowTint4,
                                                           currentSinger?.getTintColor() ?? .yellowShade4,
                                                           currentSinger?.getShadeColor() ?? .yellowShade4]),
                               startPoint: .top, endPoint: .bottom)
            )
            .onAppear {
                if !haveAppeared {
                    singers = Singer.getSingers()
                    selectedIndex = singers.count / 2
                    currentSinger = singers.isEmpty ? nil : singers[selectedIndex]
                    
                    haveAppeared = true
                }
                
                audioHandler.playAudio(
                    fileName: currentSinger?.clips.randomElement()?.id ?? "",
                    type: "mp3"
                )
            }
            .onChange(of: selectedIndex) { index in
                audioHandler.myAudioPlayer.stop() //Stop music
                currentSinger = singers.isEmpty ? nil : singers[selectedIndex]
                
                audioHandler.playAudio(
                    fileName: currentSinger?.clips.randomElement()?.id ?? "",
                    type: "mp3"
                )
            }
            .onChange(of: audioHandler.isPlaying) { isPlaying in
                print(isPlaying)
                if !isPlaying {
                    audioHandler.playAudio(
                        fileName: currentSinger?.clips.randomElement()?.id ?? "",
                        type: "mp3"
                    )
                }
            }
            .onDisappear(){
                audioHandler.myAudioPlayer.stop() //Stop music
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Image(systemName: "clock.arrow.circlepath")
                        .foregroundStyle(
                            currentSinger?.getShadeColor() ?? .yellowShade3
                        )
                        .bold()
                }
            }
            
        }
        .tint(.bg)
        
    }
    
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: History.self, configurations: config)
    
    return NavigationStack {
        HomeView()
    }
    .modelContainer(container)
    .environmentObject(AudioHandler())
}
