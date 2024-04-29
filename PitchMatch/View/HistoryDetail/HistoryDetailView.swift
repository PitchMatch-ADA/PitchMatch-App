//
//  HistoryDetailView.swift
//  PitchMatch
//
//  Created by Darren Thiores on 26/04/24.
//

import SwiftUI
import SwiftData
import AVFAudio

struct HistoryDetailView: View {
    @State var singer: Singer?
    @Query var recordings: [History] //TODO: blom init
    @State var currentSong: Song? = nil
    @EnvironmentObject private var voiceToTextParser: VoiceToTextParser
    @Environment(\.dismiss) private var dismiss
    @State var selectedSong: Int = 0
    @State private var audioPlayer: AVAudioPlayer? = nil
    
    private var overallScore: Double {
        var score = 0.0
        var count = 0.0
        for history in recordings {
            if history.singerId == singer?.id{
                score = score + history.overallScore
                count += 1
            }
        }
        return count == 0 ? 0 : score / count
    }
    
    var body: some View {
        GeometryReader { proxy in
            VStack{
                CircularProgressBar(progress: overallScore, singer: singer ?? Singer.getSingers()[0], barColor: singer?.getShadeColor() ?? .yellowShade4)
                //TODO: Slap algorithm for counting average score
                Spacer()
                TabView(selection: $selectedSong,
                        content:  {
//                                        ForEach(Singer.getSingers()) { singer in
//                                            ScrollView{
//                                                ForEach(singer.clips){ song in
//                                                    HistoryDetailCard(song: song, proxy: proxy)
//                                                }
//                                            } //place holder
//                                        }
                    ForEach(Array((singer?.clips ?? []) .enumerated()), id: \.offset){ index, song in
                        ScrollView{
                            ForEach(Array((recordings) .enumerated()), id: \.offset){
                                idx, record in
                                    if record.songId == song.id{
                                        HistoryDetailCard(record: record, song: song, proxy: proxy){
                                            Task{
                                                audioPlayer?.stop()
                                                
                                                let path = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
                                                let audioFile = path.appendingPathComponent(
                                                    record.id
                                                )
                                                
                                                audioPlayer = try? AVAudioPlayer(
                                                    contentsOf: audioFile
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
                            }
                        }
                    }
                    .padding()
                })
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .always))
                .indexViewStyle(PageIndexViewStyle(backgroundDisplayMode: .always))
                .frame(height: 400)
                .onAppear{
                    currentSong = singer?.clips[selectedSong]
                        playAudio(audioResourceId: currentSong?.id ?? "", isLoop: true)
                }
                .onChange(of: selectedSong) { index in
                    audioPlayer?.stop() //Stop music
                    currentSong = singer?.clips[selectedSong]
                    playAudio(audioResourceId: currentSong?.id ?? "", isLoop: true)
                }
                //TODO: Masih trial pake Song, jangan lupa ganti
                .onDisappear{
                    audioPlayer?.stop()
                }
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
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button(action: {
                    dismiss()
                }) {
                    Label("", systemImage: "arrow.left.circle")
                }
            }
        }
    }
    
    func playAudio(audioResourceId: String, isLoop: Bool) {
        Task{
            if let fileName = Bundle.main.path(forResource: audioResourceId, ofType: "mp3") {
                audioPlayer = try? AVAudioPlayer(contentsOf: URL(fileURLWithPath: fileName))
            }
            
            do {
                try AVAudioSession.sharedInstance().setCategory(.playback)
            } catch(let error) {
                print(error.localizedDescription)
            }
            audioPlayer?.numberOfLoops = (isLoop) ? -1 : 0
            audioPlayer?.play()
        }
    }
    
    
}

#Preview {
    HistoryDetailView(
        singer: Singer.getSingers()[2]
    )
}
