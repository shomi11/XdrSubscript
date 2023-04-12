//
//  CloudKitManager.swift
//  XdrSubscript
//
//  Created by Malovic, Milos on 11.4.23..
//

import CloudKit
import SwiftUI
import CoreData

class CloudKitManager: ObservableObject {
    @Published var tasks = [CKRecord]()
    
    let container = CKContainer(identifier: "iCloud.com.xdrdev.XdrSubscript")
    let persistentContainer = NSPersistentCloudKitContainer(name: "SubscriptionXdr")
    
    func fetchTasks() async -> [Subscription] {
        let database = container.privateCloudDatabase
        var subs: [Subscription] = []
        let query = CKQuery(recordType: "CD_Subscription", predicate:  NSPredicate(format: "CD_price > %d", 0))
        let results = try? await database.records(matching: query).matchResults.compactMap({$0.1})
        results?.forEach({ result in
            switch result {
            case .success(let rec):
                let sub = createSubFromRecord(rec)
                subs.append(sub)
            case .failure(let failure):
                print("failed \(failure)")
            }
        })
        return subs
    }
    
    private func createSubFromRecord(_ ckRecord: CKRecord) -> Subscription {
        let name = ckRecord["CD_name"] as! String
        let id = ckRecord["CD_id"] as! String
        let notificationOn = ckRecord["CD_notificationOn"] as! Bool
        let price = ckRecord["CD_price"] as! Double
        let type = ckRecord["CD_type"] as! Int16
        let startDate = ckRecord["CD_startDate"] as! Date
        let dateCreated = ckRecord["CD_dateCreated"] as! Date
        let imageUrl = ckRecord["CD_imageUrl"] as? String ?? ""
        let movedToHistory = ckRecord["CD_movedToHistory"] as! Bool
        let dateMovedToHistory = ckRecord["CD_dateMovedToHistory"] as? Date ?? Date()
        let trialActivated = ckRecord["CD_trialActivated"] as? Bool ?? false
        let trialEndDate = ckRecord["CD_trialEndDate"] as? Date ?? Date()
        let subscription = Subscription.init(context: persistentContainer.viewContext)
        subscription.id = .init(uuidString: id)!
        subscription.name = name
        subscription.startDate = startDate
        subscription.dateCreated = dateCreated
        subscription.notificationOn = notificationOn
        subscription.price = price
        subscription.dateMovedToHistory = dateMovedToHistory
        subscription.imageUrl = imageUrl
        subscription.trialActivated = trialActivated
        subscription.trialEndDate = trialEndDate
        subscription.movedToHistory = movedToHistory
        subscription.type = type
        return subscription
    }
}
