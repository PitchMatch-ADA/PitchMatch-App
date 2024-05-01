import Foundation
import SwiftUI
import AVFoundation

class AudioHandler: NSObject, ObservableObject, AVAudioPlayerDelegate {

    @Published var isPlaying: Bool = false

    var myAudioPlayer = AVAudioPlayer()

    override init() {
        super.init()
    }

    func playAudio(
        fileName: String,
        type: String
    ) {
        if let path = Bundle.main.path(
            forResource: fileName,
            ofType: type
        ) {
            let url = URL(fileURLWithPath: path)

            do {
                myAudioPlayer = try AVAudioPlayer(contentsOf: url)
                myAudioPlayer.delegate = self
                
                do {
                    try AVAudioSession.sharedInstance().setCategory(.playback)
                } catch(let error) {
                    print(error.localizedDescription)
                }
                
                isPlaying = true
                myAudioPlayer.play()
            } catch {
                // couldn't load file :(
                print(error.localizedDescription)
            }
        }
    }

    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        print("Did finish Playing")
        isPlaying = false
    }
}
