//
//  XdrSubscriptApp.swift
//  XdrSubscript
//
//  Created by Malovic, Milos on 18.11.22..
//

import SwiftUI

@main
struct XdrSubscriptApp: App {
    
    @Environment(\.scenePhase) var scene
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @StateObject private var dataController = DataController()
    @ObservedObject private var appState: AppState = AppState()

    var body: some Scene {
        WindowGroup {
            SplashView()
                .environment(\.managedObjectContext, dataController.container.viewContext)
                .environmentObject(appState)
        }
        .onChange(of: scene) { newValue in
            switch newValue {
            case .background:
                try? dataController.container.viewContext.save()
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
