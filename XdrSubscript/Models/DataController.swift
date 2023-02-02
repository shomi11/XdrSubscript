//
//  DataController.swift
//  XdrSubscript
//
//  Created by Malovic, Milos on 24.1.23..
//

import Foundation
import CoreData
import CloudKit

class DataController: ObservableObject {
   
    let container = NSPersistentCloudKitContainer(name: "SubscriptionXdr")
    
    init() {

        container.loadPersistentStores { description, error in
            
            debugPrint("Store Description: \(description)")
            if let error = error {
                print("==== Core Data failed to load: \(error.localizedDescription)")
            }
            self.container.viewContext.automaticallyMergesChangesFromParent = true
        }
        
    }
    
    static var subs: [Subscription] {
        var subsi = [Subscription]()
        for i in 0...5 {
            let s = Subscription(context: NSPersistentContainer(name: "SubscriptionXdr").viewContext)
            s.id = UUID()
            s.name = "Name \(i)"
            s.startDate = Date()
            s.notificationOn = Bool.random()
            s.price = 1900
            s.type = 0
            subsi.append(s)
        }
        return subsi
    }
}

enum iCloudStatus {
    case couldNotDetermine
    case available
    case noAccount
    case temporarilyUnavailable
    case restricted
}
