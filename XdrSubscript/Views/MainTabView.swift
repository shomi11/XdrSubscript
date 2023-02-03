//
//  MainTabView.swift
//  XdrSubscript
//
//  Created by Malovic, Milos on 18.11.22..
//

import SwiftUI
import UserNotifications

struct MainTabView: View {
    
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        TabView {
            SubscriptionListView()
                .tabItem {
                    Label("Subscriptions", systemImage: "list.dash")
                }
            InfoView()
                .environmentObject(appState)
                .tabItem {
                    Label("Info", systemImage: "info")
                }
            
            HistoryView()
                .environmentObject(appState)
                .tabItem {
                    Label("History", systemImage: "calendar.badge.clock")
                }
            
            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gear")
                }
        }
        .navigationTitle("Hello")
        .onAppear {
            UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { success, error in
                if success {
                    print("All set for notification")
                } else if let error = error {
                    print(error.localizedDescription)
                }
            }
        }
    }
}
