//
//  XdrSubscriptApp.swift
//  XdrSubscript
//
//  Created by Malovic, Milos on 18.11.22..
//

import SwiftUI
import CoreSpotlight
import BackgroundTasks
import UserNotifications

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
                try? dataController.container.viewContext.save()
            case .inactive:
                print("inactive")
            case .active:
                print("did become active")
                BGTaskScheduler.shared.getPendingTaskRequests(completionHandler: { request in
                    print("Pending task requests: \(request)")
                })
            @unknown default:
                print("defaut unknown")
            }
        }
//        .backgroundTask(.appRefresh("myapprefresh")) {
//              await setNotification()
//        }
    }
//
//    func setNotification() async { // this is the functio that will respond your scheduled background task
//        let content = UNMutableNotificationContent()
//        content.title = "A Random Photo is awaiting for you!"
//        content.subtitle = "Check it now!"
//
//        do {
//            try await UNUserNotificationCenter.current().add(UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: UNTimeIntervalNotificationTrigger(timeInterval: 10, repeats: false)))
//        }
//        catch {
//            print("SET NOTIFICATION ERRORRR \(error)")
//        }
//    }
//
//    func scheduleAppRefresh() {
//        let request = BGAppRefreshTaskRequest(identifier: "myapprefresh") // Mark 1
//        request.earliestBeginDate = .now.addingTimeInterval(20)
//        do {
//            try BGTaskScheduler.shared.submit(request) // Mark 3
//            print("Background Task Scheduled!")
//        } catch(let error) {
//            print("Scheduling ERRORRR \(error)")
//        }
//        let day = Calendar.current.startOfDay(for: .now)
//        let tommorow = Calendar.current.date(byAdding: .day, value: 0, to: day)!
//        let time = DateComponents(hour: 13, minute: 57)
//        let finalDate = Calendar.current.date(byAdding: time, to: tommorow)
//        print("FINAL DATE \(String(describing: finalDate))")
//        let request = BGAppRefreshTaskRequest(identifier: "myapprefresh")
//
//        request.earliestBeginDate = finalDate
//        do {
//            try BGTaskScheduler.shared.submit(request)
//        }
//        catch {
//            print("EEERRROR \(error)")
//        }
 //   }
}
