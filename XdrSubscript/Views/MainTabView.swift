//
//  MainTabView.swift
//  XdrSubscript
//
//  Created by Malovic, Milos on 18.11.22..
//

import SwiftUI
import UserNotifications

struct MainTabView: View {
    
    @State var user: User
    @StateObject private var appState = AppState()
    
    var body: some View {
        TabView {
            SubscriptionListView(user: user)
                .environmentObject(appState)
                .tabItem {
                    Label("Subscriptions", systemImage: "list.dash")
                }
            InfoView()
                .environmentObject(appState)
                .tabItem {
                    Label("Info", systemImage: "info")
                }
            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gear")
                }
        }
        .navigationTitle("Hello \(user.name)")
        .onAppear {
            UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { success, error in
                if success {
                    print("All set!")
                } else if let error = error {
                    print(error.localizedDescription)
                }
            }
        }
    }
}
//
//struct MainTabView_Previews: PreviewProvider {
//    static var previews: some View {
//        MainTabView(user: User.example)
//            .environmentObject(AppState())
//    }
//}
