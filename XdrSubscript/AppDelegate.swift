//
//  AppDelegate.swift
//  XdrSubscript
//
//  Created by Malovic, Milos on 18.11.22..
//

import Foundation
import SwiftUI
import Firebase
import RevenueCat

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        
        FirebaseApp.configure()
        Purchases.logLevel = .debug
        Purchases.configure(withAPIKey: "appl_YZPszunZtxCsrggdzFYoTVNPZYt")
        
        return true
    }
}


// Apple sign in callback // https://subscriptxdr.firebaseapp.com/__/auth/handler
