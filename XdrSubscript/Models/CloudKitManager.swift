//
//  CloudKitManager.swift
//  XdrSubscript
//
//  Created by Malovic, Milos on 11.4.23..
//

import CloudKit
import SwiftUI


class CloudKitManager: ObservableObject {
    @Published var tasks = [CKRecord]()
    
    let container = CKContainer(identifier: "iCloud.com.xdrdev.XdrSubscript")
    
    func fetchTasks() {
        let database = container.publicCloudDatabase
        let query = CKQuery(recordType: "CD_Subscription", predicate:  NSPredicate(format: "CD_price > %d", 0))
        //let query = CKQuery(recordType: "Subscription", predicate: NSPredicate(format: "completed == false"))
        database.fetch(withQuery: query) { result in
            switch result {
            case .success(let success):
                print(success)
            case .failure(let failure):
                print("Fetch query error \(failure)")
            }
        }
    }
}
