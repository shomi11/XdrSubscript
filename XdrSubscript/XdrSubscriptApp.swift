//
//  XdrSubscriptApp.swift
//  XdrSubscript
//
//  Created by Malovic, Milos on 18.11.22..
//

import SwiftUI
import CoreSpotlight

@main
struct XdrSubscriptApp: App {
    
    @Environment(\.scenePhase) var scene
    #if os(iOS)
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    #endif
    @StateObject private var dataController = DataController()
    @ObservedObject private var appState: AppState = AppState()
    

    var body: some Scene {
        WindowGroup {
            #if os(iOS)
            SplashView()
                .environment(\.managedObjectContext, dataController.container.viewContext)
                .environmentObject(appState)
            #else
            MainTabView()
                .environment(\.managedObjectContext, dataController.container.viewContext)
                .environmentObject(appState)
            #endif
        }
        .onChange(of: scene) { newValue in
            switch newValue {
            case .background:
                print("background")
            case .inactive:
                print("inactive")
            case .active:
                print("did become active")
            @unknown default:
                print("defaut unknown")
            }
        }
    }
}
