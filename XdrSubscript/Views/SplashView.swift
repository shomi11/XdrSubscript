//
//  SplashView.swift
//  XdrSubscript
//
//  Created by Malovic, Milos on 18.11.22..
//

import SwiftUI
import CoreData
import UserNotifications

struct SplashView: View {
    
    @Environment(\.managedObjectContext) var moc
    @EnvironmentObject var appState: AppState
    @State private var showMain: Bool = false
    @State private var hasTimeElapsed = false
    
    let timer = Timer()
        
    var body: some View {
        ZStack {
            VStack(alignment: .center, spacing: 16) {
                Image("logo")
                    .resizable()
                    .scaledToFit()
                Text("Get Better With Your Finance $")
                    .fontWeight(.heavy)
                    .font(.title3)
            }
            .padding(.horizontal)
        }
        .ignoresSafeArea(.all)
        .onAppear {
            let fetch = Subscription.fetchRequest()
            fetch.sortDescriptors = []
            let results = (try? moc.fetch(fetch) as [Subscription]) ?? []
            appState.subscriptions = results
            Task {
                await delayText()
            }
        }
        .fullScreenCover(isPresented: $showMain) {
            MainTabView()
        }
        .onChange(of: hasTimeElapsed) { newValue in
            if newValue {
                showMain = true
            }
        }
    }
    
    private func delayText() async {
        try? await Task.sleep(nanoseconds: 2_000_000_000)
        hasTimeElapsed = true
    }
}

struct SplashView_Previews: PreviewProvider {
    static var previews: some View {
        SplashView()
    }
}
