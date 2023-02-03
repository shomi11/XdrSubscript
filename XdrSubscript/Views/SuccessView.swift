//
//  SuccessView.swift
//  XdrSubscript
//
//  Created by Malovic, Milos on 23.11.22..
//

import SwiftUI

struct SuccessView: View {
    
    @State var title: String
    @State var message: String
    @Binding var showSelf: Bool
    
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "checkmark.circle")
                .resizable()
                .scaledToFit()
                .frame(maxWidth: 100)
                .foregroundColor(.green)
            VStack(alignment: .center, spacing: 8) {
                if !title.isEmpty {
                    Text(title)
                        .fontWeight(.semibold)
                }
                if !message.isEmpty {
                    Text(message)
                        .fontWeight(.medium)
                }
            }
        }
        .padding(32)
        .background(.thinMaterial)
        .cornerRadius(12)
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2, execute: {
                showSelf = false
            })
        }
    }
}

struct SuccessView_Previews: PreviewProvider {
    static var previews: some View {
        SuccessView(title: "Bravooo", message: "You did something", showSelf: .constant(true))
    }
}
