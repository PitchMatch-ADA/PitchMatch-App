//
//  HistoryListView.swift
//  PitchMatch
//
//  Created by Giventus Marco Victorio Handojo on 26/04/24.
//

import SwiftUI

struct HistoryListView: View {
    private let adaptiveColumn = [
            GridItem(.adaptive(minimum: 150))
        ]
    var body: some View {
        NavigationStack{
            ScrollView{
                LazyVGrid(columns: adaptiveColumn, spacing: 10) {
                    ForEach(0..<10){ value in
                        NavigationLink(destination:HomeView()){
                            VStack{
                                Image("RAN")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .cornerRadius(10)
                                ProgressView(value: 0.75)
                                    .accentColor(.orange)
                                    .scaleEffect(x: 1, y: 4, anchor: .center)
                                    .padding(.top,10)
                                    .padding(.bottom,20)
                                    .padding(.horizontal)
                            }
                            .background()
                            .cornerRadius(10)
                            .shadow(radius: 10)
                            
                            
                        }
                        
                    }

                }
            }
            .padding()
            .navigationTitle("Title")
            .background(
                        LinearGradient(gradient: Gradient(colors: [Color.yellowTint2, Color.yellowShade2]), startPoint: .top, endPoint: .bottom)
                            .edgesIgnoringSafeArea(.all)
                    )
            .frame(maxWidth: .infinity)
            
           
        }
        
        
        
    }
    
}

#Preview {
    HistoryListView()
}
