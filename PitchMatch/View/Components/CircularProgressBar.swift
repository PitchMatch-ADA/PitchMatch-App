//
//  CircularProgressBar.swift
//  PitchMatch
//
//  Created by Giventus Marco Victorio Handojo on 26/04/24.
//

import SwiftUI

struct CircularProgressBar: View {
    let progress:Double
       var total:Double =  100
       let circleHeight:CGFloat = 217
       @State var xPos:CGFloat = 0.0
        let singer: Singer
    
           
       @State var yPos:CGFloat = 0.0
       var body: some View {
          // let pinHeight = circleHeight * 0.1
           
           VStack {
               Image(singer.imageName)
                 .resizable()
                 .frame(width: 210, height: 210)
                 .cornerRadius(1000)
                 .scaledToFill()
                 
                   .overlay(
                    Circle()
                        .trim(from: 0.0, to: 0.7)
                        .stroke(Color(.systemGray5),style: StrokeStyle(lineWidth: 25.0, lineCap: .round, dash: [0.1]))
                        .frame(width: 278, height: 217, alignment: .center)
                        .rotationEffect(.init(degrees: 142))
                        .overlay(
                            Circle()
                                .trim(from: 0, to: progress)
                                .stroke(Color.purple,style: StrokeStyle(lineWidth: 15.0, lineCap: .round, dash: [0.1]))
                                
                                .rotationEffect(.init(degrees: 142))
                                .rotation3DEffect(
                                    .init(degrees: 1),
                                    axis: (x: 1.0, y: 0.0, z: 0.0)
                                )
                               
                        )
                   )
                   .foregroundColor(.red)
                  
               
               
               Text("70%")
                   .font(.title)
                   .fontWeight(.bold)
                   .foregroundColor(Color.white)
                   
               
               
           }

           
       }
}

#Preview {
    CircularProgressBar(progress: 0.1, singer: .init(id: "1", imageName: "RAN", clips: ["Resources/Song/RanSiLemah"]))
}
