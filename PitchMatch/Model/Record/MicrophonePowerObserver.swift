//
//  MicrophonePowerObserver.swift
//  PitchMatch
//
//  Created by Darren Thiores on 27/04/24.
//

import Foundation
import Speech
import Combine

class MicrophonePowerObserver: ObservableObject {
    private var cancellable: AnyCancellable? = nil
    private var audioRecorder: AVAudioRecorder? = nil
    
    @Published private(set) var micPowerRatio = 0.0
    @Published private(set) var fileName = ""
    
    private let powerRatioEmissionPerSecond = 20.0
    
    func startObserving() {
        do {
            let recorderSettings: [String: Any] = [
                AVFormatIDKey: NSNumber(value: kAudioFormatAppleLossless),
                AVNumberOfChannelsKey: 1
            ]
            
            let directoryURL = FileManager.default.urls(
                for: FileManager.SearchPathDirectory.documentDirectory,
                in: FileManager.SearchPathDomainMask.userDomainMask
            ).first
                    
            let audioFileName = UUID().uuidString + ".m4a"
            let audioFileURL = directoryURL!.appendingPathComponent(audioFileName)
            
            fileName = audioFileName
            
            let recorder = try AVAudioRecorder(
                url: URL(
                    fileURLWithPath: audioFileName,
                    isDirectory: true
                ),
                settings: recorderSettings
            )
            
            recorder.isMeteringEnabled = true
            recorder.record()
            self.audioRecorder = recorder
            
            self.cancellable = Timer.publish(
                every: 1.0 / powerRatioEmissionPerSecond,
                tolerance: 1.0 / powerRatioEmissionPerSecond,
                on: .main,
                in: .common
            )
            .autoconnect()
            .sink { [weak self]_ in
                recorder.updateMeters()
                
                let powerOffset = recorder.averagePower(forChannel: 0)
                
                if powerOffset < -50 {
                    self?.micPowerRatio = 0.0
                } else {
                    let normalizeOffset = CGFloat(50 + powerOffset) / 50
                    self?.micPowerRatio = normalizeOffset
                }
            }
        } catch {
            print("An error occurred when observing microphone power: \(error)")
        }
    }
    
    func release() {
        cancellable = nil
        
        audioRecorder?.stop()
        audioRecorder = nil
        
        micPowerRatio = 0.0
        fileName = ""
    }
}
