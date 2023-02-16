//
//  DynamicIslandSuccessView.swift
//  XdrSubscript
//
//  Created by Malovic, Milos on 15.2.23..
//

import SwiftUI

struct DynamicIslandSuccessView: View {
    
    @EnvironmentObject private var appState: AppState
    @State private var animated: Bool = false
    @Binding var providerName: String
    @Binding var providerPrice: Double
    @Binding var showSelf: Bool
    
    var body: some View {
        HStack(alignment: .center, spacing: 8) {
            if animated {
                Image(systemName: "checkmark.circle.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 50, height: 50, alignment: .center)
                    .foregroundColor(.green)
                    .fontWeight(.heavy)
                    .padding(.leading)
                VStack(alignment: .leading, spacing: 4) {
                    Text("\(providerName) \(providerPrice.formatted(.currency(code: appState.selectedCurrency)))")
                        .foregroundColor(.white)
                        .bold()
                    Text("added successfully")
                        .foregroundColor(.white.opacity(0.7))
                }
                Spacer()
            }
        }.frame(
            width: !animated ? 127 : UIScreen.main.bounds.width - 32,
            height: !animated ? 37 : 120,
            alignment: .center
        )
        .blur(radius: animated ? 0 : 0.5)
        .opacity(animated ? 1 : 0)
        .scaleEffect(animated ? 1 : 0.5, anchor: .top)
        .background {
            RoundedRectangle(cornerRadius: animated ? 40 : 63, style: .continuous)
                .fill(Color.black)
        }
        .opacity(animated ? 1 : 0)
        .clipped()
        .offset(y: 11)
        .onChange(of: showSelf, perform: { newValue in
            withAnimation(.spring(response: 0.5, dampingFraction: 0.5, blendDuration: 0.5)) {
                animated = true
            }
            Task {
                await sleep()
                showSelf = false
            }
        })
    }
    
    private func sleep() async {
        try? await Task.sleep(nanoseconds: 2_500_000_000)
        withAnimation(.spring(response: 1, dampingFraction: 0.5, blendDuration: 1)) {
            animated = false
        }
    }
}

struct DynamicIslandSuccessView_Previews: PreviewProvider {
    static var previews: some View {
        DynamicIslandSuccessView(providerName: .constant("YouTube premium"), providerPrice: .constant(10.99), showSelf: .constant(false))
            .environmentObject(AppState())
    }
}
