//
//  HomeView.swift
//  PitchMatch
//
//  Created by Darren Thiores on 26/04/24.
//

import SwiftUI

struct HomeView: View {
    @State private var singers: [Singer] = []
    @State private var currentSinger: Singer?
    @State private var selectedIndex: Int = 0
    
    var body: some View {
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
//                            NavigationLink {
//                                Text(singer.id)
//                            } label: {
//                                CircularProgressBar(progress: 0.4, singer: Singer(id: singer.id, imageName: singer.imageName, clips: singer.clips))
//                            }
                            CircularProgressBar(progress: 0.4, singer: Singer(id: singer.id, imageName: singer.imageName, clips: singer.clips))
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
                        Text(currentSinger?.id ?? "ran")
                    }label: {
                        CircleNav(iconName: "clock.arrow.circlepath", circleSize: 70, iconColor: currentSinger?.getShadeColor() ?? .yellowShade4, iconSize: 30)
                    }
                  
                    Spacer()
                    NavigationLink{
                        Text(currentSinger?.id ?? "ran")
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
//            LinearGradient(
//                colors: [
//                    currentSinger?.getTintColor() ?? .yellowTint4,
//                    currentSinger?.getShadeColor() ?? .yellowShade4
//                ],
//                startPoint: .top,
//                endPoint: .bottom
//            )
        )
        .onAppear {
            singers = Singer.getSingers()
            
            selectedIndex = singers.count / 2
            currentSinger = singers.isEmpty ? nil : singers[selectedIndex]
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
}

#Preview {
    NavigationStack {
        HomeView()
    }
}
