//
//  Subscription+CoreDataProperties.swift
//  XdrSubscript
//
//  Created by Malovic, Milos on 24.1.23..
//
//

import Foundation
import CoreData
import CloudKit

extension Subscription {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Subscription> {
        return NSFetchRequest<Subscription>(entityName: "Subscription")
    }

    @NSManaged public var id: UUID
    @NSManaged public var name: String
    @NSManaged public var notificationOn: Bool
    @NSManaged public var price: Double
    @NSManaged public var startDate: Date
    @NSManaged public var type: Int16
    @NSManaged public var dateCreated: Date
    @NSManaged public var imageUrl: String
    @NSManaged public var movedToHistory: Bool
    @NSManaged public var dateMovedToHistory: Date
    @NSManaged public var trialActivated: Bool
    @NSManaged public var trialEndDate: Date

}

extension Subscription : Identifiable {
    
    static var example: [Subscription] {
        var subs: [Subscription] = []
        for i in 0..<3 {
            let sub = Subscription()
            sub.id = UUID()
            sub.movedToHistory = false
            sub.name = "Name \(i)"
            sub.type = 1
            sub.notificationOn = true
            sub.dateCreated = Date()
            sub.dateMovedToHistory = Date()
            sub.price = 1100
            sub.imageUrl = "a1.rs"
            sub.startDate = Date()
            subs.append(sub)
        }
        return subs
    }
    
    func prepareCloudRecords() -> CKRecord {
        let parentName = objectID.uriRepresentation().absoluteString
        let parentID = CKRecord.ID(recordName: parentName)
        let parent = CKRecord(recordType: "Subscription", recordID: parentID)
        parent["id"] = id.uuidString
        parent["name"] = name
        parent["notifificationOn"] = notificationOn
        parent["price"] = price
        parent["startDate"] = startDate
        parent["type"] = type
        parent["dateCreated"] = dateCreated
        parent["imageUrl"] = imageUrl
        return parent
    }
}

