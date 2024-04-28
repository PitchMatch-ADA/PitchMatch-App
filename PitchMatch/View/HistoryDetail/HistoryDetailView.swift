//
//  HistoryDetailView.swift
//  PitchMatch
//
//  Created by Darren Thiores on 26/04/24.
//

import SwiftUI

struct HistoryDetailView: View {
    let singer: Singer?
    let recordings: [History] = [] //TODO: blom init
    @State var selectedSong: Int = 0
    
    var body: some View {
        GeometryReader { proxy in
            VStack{
                CircularProgressBar(progress: 10, singer: singer ?? Singer.getSingers()[0], barColor: singer?.getShadeColor() ?? .yellowShade4)
                Spacer()
                TabView(selection: $selectedSong,
                        content:  {
                    ForEach(Singer.getSingers()) { singer in
                        ScrollView{
                            ForEach(singer.clips){ song in
                                HistoryDetailCard(song: song, proxy: proxy)
                            }
                        }
                    }
                    .padding()
                })
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .always))
                .indexViewStyle(PageIndexViewStyle(backgroundDisplayMode: .always))
                //TODO: Masih trial pake Song, jangan lupa ganti
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
    }
}

#Preview {
    HistoryDetailView(
        singer: Singer.getSingers()[2]
    )
}
