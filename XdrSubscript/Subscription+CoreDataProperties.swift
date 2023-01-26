//
//  Subscription+CoreDataProperties.swift
//  XdrSubscript
//
//  Created by Malovic, Milos on 24.1.23..
//
//

import Foundation
import CoreData


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

}

extension Subscription : Identifiable {

}
