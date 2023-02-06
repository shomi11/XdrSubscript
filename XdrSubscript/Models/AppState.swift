//
//  AppState.swift
//  XdrSubscript
//
//  Created by Malovic, Milos on 23.11.22..
//

import Foundation
import CoreData
import CoreSpotlight

class AppState: ObservableObject {
   
    @Published var subscriptions: [Subscription] = []
    @Published var maxSpending = UserDefaults(suiteName: .accessGroup)?.value(forKey: "max_spending") as? Double ?? 0.0
    @Published var userName = UserDefaults(suiteName: .accessGroup)?.value(forKey: "userName") as? String ?? ""
    @Published var selectedCurrency = UserDefaults(suiteName: .accessGroup)?.value(forKey: "selectedCurrency") as? String ?? "USD"
    @Published var loadingState: LoadingState = .loading
    
    func nextSub() -> [DaysLeft]? {
        
        var daysLeftSubs: [DaysLeft] = []
        
        if !subscriptions.isEmpty {
            for subscription in subscriptions.filter({$0.movedToHistory == false}) {
                let comp = Calendar.current.dateComponents([.day], from: subscription.startDate)
              
                let newDay = Calendar.current.date(from: comp)
                let dayInMonth = newDay!.day
                
                let now = Date()
                
                let c = Calendar.current.component(.year, from: now)
                
                var nextComp = DateComponents()
                nextComp.day = dayInMonth
                nextComp.year = c

                let nowNextMonthDay = Calendar.current.date(from: nextComp)
               
                let nextMonth = Calendar.current.date(byAdding: .month, value: 1, to: nowNextMonthDay!)
                
                let dayLeft = Calendar.current.numberOf24DaysBetween(.now, and: nextMonth!)
                let d = DaysLeft.init(sub: subscription, daysLeft: dayLeft)
                daysLeftSubs.append(d)
            }
        }
        return daysLeftSubs
    }
    
    
    var totalSubscriptionsPriceMonthly: Double {
        return subscriptions.filter({$0.movedToHistory == false}).filter({$0.model == .monthly}).reduce(0) {  $0 + $1.price }
    }
    
    var totalSubscriptionsPriceYearly: Double {
        return subscriptions.filter({$0.movedToHistory == false}).filter({$0.model == .yearly}).reduce(0) {  $0 + $1.price }
    }
    
    var theMostExpensiveSubscription: Subscription? {
        subscriptions.filter({$0.movedToHistory == false}).first(where: {$0.price == subscriptions.compactMap({$0.montlyPrice}).max()})
    }
    
    var totalMonthlyAndYearlyPerMonth: Double {
        totalSubscriptionsPriceMonthly + (totalSubscriptionsPriceYearly / 12)
    }
    
    var groupedByMonth: [GroupedByMonthSubscriptions] {
        
        var groupedByMonthSubscriptions: [GroupedByMonthSubscriptions] = []
        
        let groupDic = Dictionary(grouping: subscriptions.filter({$0.movedToHistory == false})) { (pendingCamera) -> DateComponents in
            let date = Calendar.current.dateComponents([.month], from: (pendingCamera.startDate))
            return date
        }
        
        groupDic.forEach { key, value in
            let g = GroupedByMonthSubscriptions(id: UUID(), month: key.month ?? 1, elemetns: value)
            groupedByMonthSubscriptions.append(g)
        }
        
        return groupedByMonthSubscriptions
    }
    
    func addSubscriptionToSpotlight(_ subscription: Subscription) {
        let id = subscription.objectID.uriRepresentation().absoluteString
        let attributeSet = CSSearchableItemAttributeSet.init(contentType: .text)
        attributeSet.title = subscription.name
        print("=== id \(id)")
        let type = subscription.model == .yearly ? "year" : "month"
        attributeSet.contentDescription = "\(subscription.priceTxt)/\(type)"
        
        let searchableSubscription = CSSearchableItem.init(uniqueIdentifier: id, domainIdentifier: id, attributeSet: attributeSet)
        CSSearchableIndex.default().indexSearchableItems([searchableSubscription]) { error in
            if let error = error {
                print("ERROR: == Searchable item core spot light: \(error)")
            }
        }
    }
    
    func convertSpotLightItemToSubscription(_ identifier: String, context: NSManagedObjectContext) -> Subscription? {
        guard let url = URL(string: identifier) else { return nil }
        guard let id = context.persistentStoreCoordinator?.managedObjectID(forURIRepresentation: url) else { return nil }
        return try? context.existingObject(with: id) as? Subscription
    }
}

extension Calendar {
    func numberOf24DaysBetween(_ from: Date, and to: Date) -> Int {
        let numberOfDays = dateComponents([.day], from: from, to: to)
        
        return numberOfDays.day! + 1
    }
}

struct DaysLeft {
    let id = UUID()
    var sub: Subscription
    var daysLeft: Int
}


