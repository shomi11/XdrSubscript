//
//  BackgroundView.swift
//  XdrSubscript
//
//  Created by Malovic, Milos on 1.2.23..
//

import SwiftUI

struct BackgroundView: View {
        
    var body: some View {
        #if os(iOS)
        ZStack {
            let uiImage = UIImage(named: "bg")!.resize(height: UIScreen.main.bounds.height)
            Image(uiImage: uiImage)
                .resizable()
                .scaledToFill()
                .edgesIgnoringSafeArea(.all)
            Rectangle()
                .fill(Color.lightLinear1.opacity(0.2))
                .background(.ultraThinMaterial)
        }
        #else
        ZStack {
            Image(nsImage: NSImage(named: "bg")!)
                .resizable()
                .scaledToFill()
                .edgesIgnoringSafeArea(.all)
            Rectangle()
                .fill(Color.lightLinear1.opacity(0.2))
                .background(.ultraThinMaterial)
        }
        #endif
    }
}

struct BackgroundView_Previews: PreviewProvider {
    static var previews: some View {
        BackgroundView()
    }
}
