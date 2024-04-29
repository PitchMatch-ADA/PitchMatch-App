//
//  HistoryDetailCard.swift
//  PitchMatch
//
//  Created by Nathanael Juan Gauthama on 27/04/24.
//

import SwiftUI

struct HistoryDetailCard: View {
    @State var record: History?
    @State var song: Song? //TODO: nnti ganti History just wanna test some things
    @State var currentSinger: Singer?
    var proxy: GeometryProxy
    let onClickButton: () -> Void
    
    var body: some View {
        
            HStack(){
                Text("\(Int(record?.overallScore ?? 0))%")
                    .foregroundStyle(currentSinger?.getPrimaryColor() ?? .yellowMain)
                    .font(.title3)
                    .fontWeight(/*@START_MENU_TOKEN@*/.bold/*@END_MENU_TOKEN@*/)
                //            RecorderDisplay(backgroundRatios: song.powerRatios.map{ ratio in
                //                Double(truncating: ratio as NSNumber)
                //            },
                //                            powerRatios: song.powerRatios.map{ ratio in
                //                Double(truncating: ratio as NSNumber)
                //            },
                //                            color: Color.yellowMain)
                
                RecorderDisplay(backgroundRatios: song?.powerRatios.map{ ratio in
                    Double(truncating: ratio as NSNumber)
                } ?? [], powerRatios: record?.processPowerFloatArrayString().map{ ratio in
                    Double(truncating: ratio as NSNumber)} ?? [], color: currentSinger?.getPrimaryColor() ?? Color.yellowMain, proxy: proxy, height: 25
                ,isLoading: false)
                Button{
                    onClickButton()
                } label: {
                    CircleNav(iconName: "play.fill", circleSize: 40, iconColor: .white, iconSize: 20, backgroundColor: currentSinger?.getPrimaryColor() ?? Color.yellowMain)
                }
            }
            .frame(height: 100)
            .padding(.horizontal, 10)
            .background(Color.bg)
            .clipShape(.rect(cornerSize: CGSize(width: 10, height: 10)))
            .onAppear{
                currentSinger = Singer.getSinger(singerId: record?.singerId ?? "Tulus")
            }
        }
}

//#Preview {
//    GeometryReader { proxy in
//        HistoryDetailCard(
//            song: Song.getSongs()[1],
//            proxy: proxy
//        ){
//            
//        }
//    }
//}
