//
//  SplashView.swift
//  XdrSubscript
//
//  Created by Malovic, Milos on 18.11.22..
//

import SwiftUI
import CoreData
import UserNotifications
import CloudKit

struct SplashView: View {
    
    @Environment(\.horizontalSizeClass) var horizontalSizeClass: UserInterfaceSizeClass?
    @Environment(\.verticalSizeClass) var verticalSizeClass: UserInterfaceSizeClass?
    @Environment(\.managedObjectContext) var moc
    @EnvironmentObject var appState: AppState
    @State private var showMain: Bool = false
    @State private var hasTimeElapsed = false
    
    let keys = ["dateCreated, id, imageUrl, name, notificationOn, price, startDate, type"]
    
    let timer = Timer()
        
    var body: some View {
        ZStack {
            VStack(alignment: .center, spacing: 16) {
                Image("logo")
                    .resizable()
                    .scaledToFit()
                    .clipShape(Circle())
                HStack(alignment: .center, spacing: 4) {
                    Text("Get Better With Your Finance")
                    Image(systemName: "dollarsign.circle")
                        .foregroundStyle(.yellow)
                }
                .fontWeight(.heavy)
                .font(.title3)
            }
            .padding()
        }
        .ignoresSafeArea(.all)
        .onAppear {
            Task {
               // await getSubscriptions()
                await sleep()
            }
        }
        #if os(iOS)
        .fullScreenCover(isPresented: $showMain) {
            if horizontalSizeClass == .regular && verticalSizeClass == .regular {
                SubscriptionListiPadOS()
            } else {
                MainTabView()
            }
        }
        #endif
        .onChange(of: hasTimeElapsed) { newValue in
            if newValue {
                showMain = true
            }
        }
    }
    
    private func sleep() async {
        try? await Task.sleep(nanoseconds: 2_000_000_000)
        hasTimeElapsed = true
    }
    
    private func getSubscriptions() async {
         moc.performAndWait({
            let fetch = Subscription.fetchRequest()
            fetch.sortDescriptors = []
            fetch.resultType = .managedObjectResultType
            if let results = (try? moc.fetch(fetch) as [Subscription]), results.isEmpty == false {
                appState.subscriptions = results
            }
        })
    }
}

struct SplashView_Previews: PreviewProvider {
    static var previews: some View {
        SplashView()
    }
}
