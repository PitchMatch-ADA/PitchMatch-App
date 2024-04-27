//
//  VoiceToTextParser.swift
//  PitchMatch
//
//  Created by Darren Thiores on 27/04/24.
//

import Foundation
import Speech
import Combine

class VoiceToTextParser: ObservableObject {
    @Published var result: String = ""
    @Published var error: String? = nil
    @Published var powerRatio: CGFloat = 0.0
    @Published var fileName: String = ""
    @Published var isSpeaking: Bool = false
    
    private var micObserver = MicrophonePowerObserver()
    var micPowerRatio: Published<Double>.Publisher {
        micObserver.$micPowerRatio
    }
    var audioFileName: Published<String>.Publisher {
        micObserver.$fileName
    }
    private var micPowerCancellable: AnyCancellable?
    private var fileNameCancellable: AnyCancellable?
    
    private var recognizer: SFSpeechRecognizer?
    private var audioEngine: AVAudioEngine?
    private var inputNode: AVAudioInputNode?
    private var audioBufferRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private var audioSession: AVAudioSession?
    
    func reset() {
        self.stopListening()
        self.result = ""
        self.error = nil
        self.powerRatio = 0.0
        self.isSpeaking = false
    }
    
    func startListening(languageCode: String) {
        updateState(error: nil)
        
        let chosenLocale = Locale.init(identifier: languageCode)
        let supportedLocale = SFSpeechRecognizer.supportedLocales().contains(chosenLocale) ? chosenLocale : Locale.init(identifier: "en-US")
        
        self.recognizer = SFSpeechRecognizer(locale: supportedLocale)
        
        guard recognizer?.isAvailable == true else {
            updateState(
                error: "Speech recognizer is not available"
            )
            return
        }
        
        audioSession = AVAudioSession.sharedInstance()
        
        self.requestPermission { [weak self] in
            self?.audioBufferRequest = SFSpeechAudioBufferRecognitionRequest()
            
            guard let audioBufferRequest = self?.audioBufferRequest else {
                return
            }
            
            self?.recognitionTask = self?.recognizer?.recognitionTask(
                with: audioBufferRequest
            ) { [weak self] (result, error) in
                guard let result = result else {
                    self?.updateState(
                        error: error?.localizedDescription
                    )
                    return
                }
                
                if result.isFinal {
                    self?.updateState(
                        result: result.bestTranscription.formattedString
                    )
                }
            }
            
            self?.audioEngine = AVAudioEngine()
            self?.inputNode = self?.audioEngine?.inputNode
            
            let recordingFormat = self?.inputNode?.outputFormat(forBus: 0)
            self?.inputNode?.installTap(
                onBus: 0,
                bufferSize: 1024,
                format: recordingFormat
            ) { buffer, _ in
                self?.audioBufferRequest?.append(buffer)
            }
            
            self?.audioEngine?.prepare()
            
            do {
                try self?.audioSession?.setCategory(
                    .playAndRecord,
                    mode: .spokenAudio,
                    options: .duckOthers
                )
                
                try self?.audioSession?.setActive(
                    true,
                    options: .notifyOthersOnDeactivation
                )
                
                self?.micObserver.startObserving()
                
                try self?.audioEngine?.start()
                
                self?.updateState(isSpeaking: true)
                
                self?.micPowerCancellable = self?.micPowerRatio
                    .sink { [weak self] ratio in
                        self?.updateState(
                            powerRatio: ratio
                        )
                    }
                
                self?.fileNameCancellable = self?.$fileName
                    .sink { [weak self] name in
                        self?.updateState(
                            fileName: name
                        )
                    }
                
            } catch {
                self?.updateState(
                    error: error.localizedDescription,
                    isSpeaking: false
                )
            }
        }
    }
    
    func stopListening() {
        self.updateState(
            isSpeaking: false
        )
        
        micPowerCancellable = nil
        micObserver.release()
        
        audioBufferRequest?.endAudio()
        audioBufferRequest = nil
        
        audioEngine?.stop()
        
        inputNode?.removeTap(onBus: 0)
        
        try? audioSession?.setActive(false)
        audioSession = nil
    }
    
    private func requestPermission(
        onGranted: @escaping () -> Void
    ) {
        audioSession?.requestRecordPermission { [weak self] wasGranted in
            if !wasGranted {
                self?.updateState(
                    error: "you need to grant permission to record your voice."
                )
                
                self?.stopListening()
                return
            }
            
            SFSpeechRecognizer.requestAuthorization { [weak self] status in
                DispatchQueue.main.async {
                    if status != .authorized {
                        self?.updateState(
                            error: "you need to grant permission to transcribe audio."
                        )
                        
                        self?.stopListening()
                        return
                    }
                    
                    onGranted()
                }
            }
        }
    }
    
    private func updateState(
        result: String? = nil,
        error: String? = nil,
        powerRatio: CGFloat? = nil,
        fileName: String? = nil,
        isSpeaking: Bool? = nil
    ) {
        self.result = result ?? ""
        self.error = error
        self.powerRatio = powerRatio ?? 0.0
        self.fileName = fileName ?? ""
        self.isSpeaking = isSpeaking ?? false
    }
}
