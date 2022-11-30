//
//  EmptyView.swift
//  XdrSubscript
//
//  Created by Malovic, Milos on 23.11.22..
//

import SwiftUI

struct EmptyView: View {
    var body: some View {
        VStack(alignment: .center, spacing: 16) {
            Image(systemName: "hand.tap")
                .resizable()
                .scaledToFit()
                .frame(maxWidth: 200)
                .foregroundColor(.secondary)
            Text("Your subscriptions are currently empty.")
                .font(.title2)
                .fontWeight(.medium)
                .multilineTextAlignment(.center)
        }
        .padding(32)
    }
}

struct EmptyView_Previews: PreviewProvider {
    static var previews: some View {
        EmptyView()
    }
}
