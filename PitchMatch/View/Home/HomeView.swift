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
    @State private var audioPlayer: AVAudioPlayer? = nil
    @State var currentSong: Song? = nil
    
    @Query private var histories: [History]
    
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
                
                if let fileName = Bundle.main.path(
                    forResource: currentSinger?.clips.randomElement()?.id ?? "",
                    ofType: "mp3"
                ) {
                    audioPlayer = try? AVAudioPlayer(
                        contentsOf: URL(fileURLWithPath: fileName)
                    )
                    
                    do {
                        try AVAudioSession.sharedInstance().setCategory(.playback)
                    } catch(let error) {
                        print(error.localizedDescription)
                    }
                    
                    audioPlayer?.play()
                }
            }
            .onChange(of: selectedIndex) { index in
                audioPlayer?.stop() //Stop music
                currentSinger = singers.isEmpty ? nil : singers[selectedIndex]
                
                if let fileName = Bundle.main.path(
                    forResource: currentSinger?.clips.randomElement()?.id ?? "",
                    ofType: "mp3"
                ) {
                    audioPlayer = try? AVAudioPlayer(
                        contentsOf: URL(fileURLWithPath: fileName)
                    )
                    
                    do {
                        try AVAudioSession.sharedInstance().setCategory(.playback)
                    } catch(let error) {
                        print(error.localizedDescription)
                    }
                    
                    audioPlayer?.play()
                }
            }
            .onChange(of: audioPlayer?.isPlaying) { isPlaying in
                if isPlaying == false {
                    if let fileName = Bundle.main.path(
                        forResource: currentSinger?.clips.randomElement()?.id ?? "",
                        ofType: "mp3"
                    ) {
                        audioPlayer = try? AVAudioPlayer(
                            contentsOf: URL(fileURLWithPath: fileName)
                        )
                        
                        do {
                            try AVAudioSession.sharedInstance().setCategory(.playback)
                        } catch(let error) {
                            print(error.localizedDescription)
                        }
                        
                        audioPlayer?.play()
                    }
                }
            }
            .onDisappear(){
                audioPlayer?.stop() //Stop music
                audioPlayer = nil
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
        .tint(currentSinger?.getShadeThreeColor() ?? .yellowShade3)
        
    }
    
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: History.self, configurations: config)
    
    return NavigationStack {
        HomeView()
    }
    .modelContainer(container)
}
