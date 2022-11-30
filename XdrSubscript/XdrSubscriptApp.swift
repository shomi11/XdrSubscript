//
//  XdrSubscriptApp.swift
//  XdrSubscript
//
//  Created by Malovic, Milos on 18.11.22..
//

import SwiftUI

@main
struct XdrSubscriptApp: App {
    
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        WindowGroup {
            SplashView()
        }
    }
}
