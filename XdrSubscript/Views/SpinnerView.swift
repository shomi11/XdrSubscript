//
//  SpinnerView.swift
//  XdrSubscript
//
//  Created by Malovic, Milos on 23.11.22..
//

import SwiftUI

struct SpinnerView: View {
    
    @State var animate: Bool = true
    
    var body: some View {
        VStack {
            ZStack(alignment: .center) {
                Circle()
                    .frame(width: 120, height: 120, alignment: .center)
                    .foregroundColor(.clear)
                Image("logo")
                    .resizable()
                    .scaledToFit()
                    .clipShape(Circle())
                    .frame(width: 100, height: 100, alignment: .center)
                    .rotationEffect(.init(degrees: animate ? 360 : 0))
                    .animation(.linear(duration: 0.7).repeatForever(autoreverses: false), value: animate)
                    Circle()
                    .trim(from: 0, to: 0.4).stroke(Color.purple, style: .init(lineWidth: 4, lineCap: .round, lineJoin: .round))
                        .frame(width: 110, height: 110, alignment: .center)
                        .rotationEffect(.init(degrees: animate ? 360 : 0))
                        .animation(.linear(duration: 0.7).repeatForever(autoreverses: false), value: animate)
            }
            .padding(16)
            .background(.thinMaterial)
            .cornerRadius(12)
            
        }
        .onAppear {
            animate.toggle()
        }
        .onDisappear {
            animate = false
        }
    }
}

struct SpinnerView_Previews: PreviewProvider {
    static var previews: some View {
        SpinnerView()
    }
}
