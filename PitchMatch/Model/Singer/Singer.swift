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
    let clips: [String]
    
    init(id: String, imageName: String, clips: [String]) {
        self.id = id
        self.imageName = imageName
        self.clips = clips
    }
    
    static func getSingers() -> [Singer] {
        return [
            Singer(
                id: "ArdhitoPramono",
                imageName: "ArdhitoPramono",
                clips: [
                    "Resources/Song/APDisenayan",
                    "Resources/Song/APSudah",
                    "Resources/Song/APTemanPerjalan"
                ]
            ),
            Singer(
                id: "Ran",
                imageName: "Ran",
                clips: [
                    "Resources/Song/RanAkanKulakukanSemuaUntukmu",
                    "Resources/Song/RanDekatDiHati",
                    "Resources/Song/RanSiLemah"
                ]
            ),
            Singer(
                id: "Tulus",
                imageName: "Tulus",
                clips: [
                    "Resources/Song/Tulus1000Tahun",
                    "Resources/Song/TulusHatiHatiDiJalan",
                    "Resources/Song/TulusTemanHidup"
                ]
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
    
    func getRandomClip() -> String? {
        return clips.randomElement()
    }
}
