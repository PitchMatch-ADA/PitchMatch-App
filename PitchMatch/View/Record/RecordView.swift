//
//  RecordView.swift
//  PitchMatch
//
//  Created by Darren Thiores on 26/04/24.
//

import SwiftUI
import AVFoundation

struct RecordView: View {
    @Environment(\.modelContext) var context
    @EnvironmentObject private var voiceToTextParser: VoiceToTextParser
    @Environment(\.dismiss) private var dismiss
    
    let singer: Singer?
    
    @State private var clip: Song? = nil
    @State private var audioPlayer: AVAudioPlayer? = nil
    @State private var songPowerRatios: [Float] = []
    @State private var userPowerRatios: [Float] = []
    
    @State private var timer = Timer.publish(every: 0.05, on: .main, in: .common).autoconnect()
    @State private var recordTimer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    @State private var receiveRecordTimer = false
    @State private var receiveTime = 0
    @State private var startTime = 3
    @State private var currentSecond = 0
    
    @State private var isLoading: Bool = true
    @State private var finishFirstTime: Bool = false
    @State private var isPlaying: Bool = false
    @State private var showRepeatButton: Bool = false
    
    @State private var isRecording: Bool = false
    @State private var finishRecording: Bool = false
    
    @State private var overallResult: Double = 0
    @State private var recentlyPlayed: Bool = false
    
    private var currentTimeText: String {
        let currentMinute = currentSecond / 60
        let minuteText = (currentMinute > 9) ? "\(currentMinute)" : "0\(currentMinute)"
        let secondLeft = currentSecond % 60
        let secondText = (secondLeft > 9) ? "\(secondLeft)" : "0\(secondLeft)"
        
        return "\(minuteText):\(secondText)"
    }
    
    private var clipTimeText: String {
        let clipSecond = clip?.second ?? 0
        let clipMinute = clipSecond / 60
        let clipMinuteText = (clipMinute > 9) ? "\(clipMinute)" : "0\(clipMinute)"
        let clipSecondLeft = clipSecond % 60
        let clipSecondText = (clipSecondLeft > 9) ? "\(clipSecondLeft)" : "0\(clipSecondLeft)"
        
        return "\(clipMinuteText):\(clipSecondText)"
    }
    
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
                    .frame(height: 24)
                
                RecorderDisplay(
                    backgroundRatios: clip?.powerRatios.map { ratio in
                        Double(truncating: ratio as NSNumber)
                    } ?? [],
                    powerRatios: songPowerRatios.map { ratio in
                        Double(truncating: ratio as NSNumber)
                    },
                    color: singer?.getPrimaryColor() ?? .yellowMain,
                    proxy: proxy,
                    height: 256,
                    isLoading: isLoading
                )
                
                Text("\(currentTimeText) / \(clipTimeText)")
                    .font(.headline)
                    .foregroundStyle(.white)
                
                Spacer()
                
                HStack {
                    if finishFirstTime && showRepeatButton {
                        let disabled = isPlaying || isLoading
                        
                        CircleButton(
                            iconName: "arrow.circlepath",
                            onClick: {
                                songPowerRatios = []
                                timer = Timer.publish(every: 0.05, on: .main, in: .common).autoconnect()
                                receiveTime = 0
                                currentSecond = 0
                                isLoading = true
                                
                                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                    isLoading = false
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
                    
                    let disabled = !finishFirstTime || isPlaying || isLoading || isRecording || finishRecording
                    
                    CircleButton(
                        iconName: "mic.fill",
                        onClick: {
                            voiceToTextParser.requestPermission {
                                receiveRecordTimer = true
                                showRepeatButton = false
                                
                                songPowerRatios = []
                                timer = Timer.publish(every: 0.05, on: .main, in: .common).autoconnect()
                                receiveTime = 0
                                currentSecond = 0
                            }
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
        .overlay {
            if receiveRecordTimer {
                ZStack {
                    Color.black
                        .opacity(0.5)
                        .ignoresSafeArea()
                    
                    ZStack {
                        Circle()
                            .trim(
                                from: 0.0,
                                to: CGFloat(startTime) / 3
                            )
                            .stroke(
                                .white,
                                style: StrokeStyle(
                                    lineWidth: 10,
                                    lineCap: .round
                                )
                            )
                            .frame(width: 120, height: 120)
                            .rotation3DEffect(Angle(degrees: 270), axis: (x: 0, y: 0, z: 1))
                            .animation(.linear, value: startTime)
                        
                        Text("\(startTime)")
                            .font(.system(size: 96))
                            .bold()
                            .foregroundStyle(.white)
                    }
                }
            }
        }
        .onAppear {
            let randomClip = singer?.getRandomClip()
            clip = randomClip
        }
        .onDisappear {
            audioPlayer?.stop()
            timer.upstream.connect().cancel()
            recordTimer.upstream.connect().cancel()
            voiceToTextParser.stopListening()
            
            audioPlayer = nil
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
            if (audioPlayer?.isPlaying ?? false || !songPowerRatios.isEmpty) && !isRecording && !finishRecording {
                print(receiveTime)
                
                songPowerRatios.append(clip?.powerRatios[receiveTime] ?? 0.0)
                receiveTime += 1
                
                if (receiveTime%20) == 0 {
                    currentSecond += 1
                }
                
                if (receiveTime/20) == clip?.second {
                    timer.upstream.connect().cancel()
                    isPlaying = false
                    finishFirstTime = true
                    showRepeatButton = true
                }
            }
            
            if isRecording {
                songPowerRatios.append(Float(voiceToTextParser.powerRatio))
                receiveTime += 1
                
                if (receiveTime%20) == 0 {
                    currentSecond += 1
                }
                
                if (receiveTime/20) == clip?.second {
                    timer.upstream.connect().cancel()
                    voiceToTextParser.stopListening()
                    isRecording = false
                    finishRecording = true
                    
                    userPowerRatios = songPowerRatios
                }
            }
            
            if finishRecording && isPlaying {
                print(receiveTime)
                
                userPowerRatios.append(songPowerRatios[receiveTime])
                receiveTime += 1
                
                if (receiveTime%20) == 0 {
                    currentSecond += 1
                }
                
                if (receiveTime/20) == clip?.second {
                    timer.upstream.connect().cancel()
                    isPlaying = false
                    recentlyPlayed = false
                }
            }
        }
        .onReceive(recordTimer) { _ in
            if receiveRecordTimer {
                startTime -= 1
                
                if startTime == 0 {
                    receiveRecordTimer = false
                    recordTimer.upstream.connect().cancel()
                    
                    if let fileName = Bundle.main.path(forResource: clip?.instrument, ofType: "mp3") {
                        audioPlayer = try? AVAudioPlayer(contentsOf: URL(fileURLWithPath: fileName))
                    }
                    
                    do {
                        try AVAudioSession.sharedInstance().setCategory(.playback)
                    } catch(let error) {
                        print(error.localizedDescription)
                    }
                    
                    audioPlayer?.play()
                    
                    voiceToTextParser.startListening(languageCode: "id")
                    isRecording = true
                    
                    isPlaying = true
                    
                    startTime = 3
                }
            }
        }
        .fullScreenCover(isPresented: $finishRecording) {
            RecordResultView(
                singer: singer,
                clip: clip,
                result: overallResult,
                waves: userPowerRatios,
                isPlaying: isPlaying,
                onDismissClick: {
                    audioPlayer?.stop()
                    dismiss()
                },
                onPlayClick: {
                    if audioPlayer?.isPlaying == true {
                        audioPlayer?.stop()
                        recentlyPlayed = true
                        isPlaying = false
                    } else {
                        if recentlyPlayed {
                            audioPlayer?.play()
                            isPlaying = true
                        } else {
                            Task {
                                userPowerRatios = []
                                
                                timer = Timer.publish(every: 0.05, on: .main, in: .common).autoconnect()
                                receiveTime = 0
                                
                                audioPlayer?.stop()
                                
                                let path = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
                                let audioFile = path.appendingPathComponent(
                                    voiceToTextParser.fileName
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
                                isPlaying = true
                            }
                        }
                    }
                }
            )
        }
        .onChange(of: voiceToTextParser.result) { _ in
            let result = analyseResult()
            
            overallResult = result
            saveResult(
                result: result
            )
        }
    }
    
    private func analysePowerResult() -> Double {
        let clipRatios = clip?.powerRatios ?? []
        var correct: Int = 0
        
        for (i, ratio) in clipRatios.enumerated() {
            if i < songPowerRatios.count {
                let resultRatio = songPowerRatios[i]
                let minCorrect = (ratio - 0.2) <= resultRatio
                let maxCorrect = (ratio + 0.2) >= resultRatio
                
                if minCorrect && maxCorrect {
                    correct += 1
                }
            }
        }
        
        let ratiosResult: Double = (Double(correct) / Double( clipRatios.count)) * 100
        
        return ratiosResult
    }
    
    private func analyseLyricResult() -> Double {
        let lyric = voiceToTextParser.result
        let result = LyricClassifier.predict(lyric: lyric)
        let lyricResult = result * 100
        
        return lyricResult
    }
    
    private func analyseResult() -> Double {
        let powerResult = analysePowerResult()
        let lyricResult = analyseLyricResult()
        
        print(powerResult)
        print(lyricResult)
        
        return (powerResult + lyricResult) / 2
    }
    
    private func saveResult(result: Double) {
        guard let singerId = singer?.id else {
            print("Singer null")
            return
        }
        guard let songId = clip?.id else {
            print("Song null")
            return
        }
        
        let history = History(
            id: voiceToTextParser.fileName,
            singerId: singerId,
            powerRatios: History.processFloatArrayToString(
                array: songPowerRatios
            ),
            frequencies: "",
            songId: songId,
            overallScore: result
        )
        
        history.insert(context: context)
    }
}

#Preview {
    RecordView(
        singer: Singer.getSingers()[2]
    )
    .environmentObject(VoiceToTextParser())
}
