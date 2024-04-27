//
//  Singer.swift
//  PitchMatch
//
//  Created by Darren Thiores on 26/04/24.
//

import Foundation

class Singer: Identifiable {
    let id: String
    let imageName: String
    let clips: [Song]
    
    init(id: String, imageName: String, clips: [Song]) {
        self.id = id
        self.imageName = imageName
        self.clips = clips
    }
    
    static func getSingers() -> [Singer] {
        return [
            Singer(
                id: "ArdhitoPramono",
                imageName: "ArdhitoPramono",
                clips: Song.getAP()
            ),
            Singer(
                id: "Ran",
                imageName: "RAN",
                clips: Song.getRan()
            ),
            Singer(
                id: "Tulus",
                imageName: "Tulus",
                clips: Song.getTulus()
            )
        ]
    }
    
    static func getSinger(
        singerId: String
    ) -> Singer? {
        let singers = getSingers()
        
        return singers.first { singer in
            singer.id == singerId
        }
    }
    
    func getRandomClip() -> Song? {
        return clips.randomElement()
    }
}
