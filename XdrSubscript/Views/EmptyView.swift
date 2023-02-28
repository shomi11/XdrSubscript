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
        VStack(alignment: .center, spacing: 48) {
            Image(systemName: "list.dash")
                .resizable()
                .scaledToFit()
                .frame(maxWidth: 100)
                .foregroundColor(.secondary)
            VStack(alignment: .center, spacing: 8) {
                Text("Your subscription list is currently empty.")
                    .font(.title3)
                    .fontWeight(.semibold)
                Text("Let's get started with one.")
                    .foregroundColor(.primary.opacity(0.7))
                    .fontWeight(.medium)
            }
            .multilineTextAlignment(.center)
            Button {
                showNewSubscriptionView.toggle()
            } label: {
                HStack(alignment: .center, spacing: 8) {
                    Text("Add Subcription")
                    Image(systemName: "plus")
                }
                .bold()
                .padding(.vertical, 6)
                .padding(.horizontal, 24)
            }
            .tint(.indigo)
            .buttonStyle(.bordered)
        }
        .padding(16)
    }
}

struct EmptyListView_Previews: PreviewProvider {
    static var previews: some View {
        EmptyListView(showNewSubscriptionView: .constant(false))
    }
}
