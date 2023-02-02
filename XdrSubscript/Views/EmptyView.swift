//
//  EmptyView.swift
//  XdrSubscript
//
//  Created by Malovic, Milos on 23.11.22..
//

import SwiftUI

struct EmptyListView: View {
    
    @Binding var showNewSubscriptionView: Bool
    
    var body: some View {
        VStack(alignment: .center, spacing: 16) {
            Image(systemName: "hand.tap")
                .resizable()
                .scaledToFit()
                .frame(maxWidth: 100)
                .foregroundColor(.secondary)
            VStack(alignment: .leading, spacing: 8) {
                Text("Your subscriptions are currently empty.")
                    .font(.title3)
                    .fontWeight(.semibold)
                    .multilineTextAlignment(.center)
                Text("Let's get started with one.")
                    .foregroundColor(.primary.opacity(0.7))
                    .fontWeight(.medium)
            }
            Button {
                showNewSubscriptionView.toggle()
            } label: {
                HStack(alignment: .center, spacing: 8) {
                    Text("Add Subcription")
                        .fontWeight(.medium)
                    Image("logo")
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: 20)
                        .clipShape(RoundedRectangle(cornerRadius: 4))
                }
                .padding(.vertical, 6)
                .padding(.horizontal, 24)
            }
            .tint(.indigo)
            .buttonStyle(.bordered)
        }
        .padding(32)
    }
}

struct EmptyListView_Previews: PreviewProvider {
    static var previews: some View {
        EmptyListView(showNewSubscriptionView: .constant(false))
    }
}
