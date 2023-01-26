//
//  AppState.swift
//  XdrSubscript
//
//  Created by Malovic, Milos on 23.11.22..
//

import Foundation
import CoreData

class AppState: ObservableObject {
   
    @Published var subscriptions: [Subscription] = []
    
    
    func nextSub() -> [Subscription]? {
        
        var subTuple: [(daysLeft: Int, sub: Subscription)]? = []
        
        for subscription in subscriptions {
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
            
            print("=== next month \(DateFormatter.localizedString(from: nextMonth!, dateStyle: .full, timeStyle: .none))")
            
            print("=== now month day \(DateFormatter.localizedString(from: nowNextMonthDay!, dateStyle: .full, timeStyle: .none))")
            
            let dayLeft = Calendar.current.numberOf24DaysBetween(.now, and: nextMonth!)
            let tup = (dayLeft, subscription)
            subTuple?.append(tup)
        }
        let sorted = subTuple?.sorted(by: {$0.daysLeft < $1.daysLeft})
        let subs = sorted?.compactMap({$0.sub})
        if let subs = subs {
            let arr = Array(subs.prefix(4))
            return arr
        } else {
            return nil
        }
    }
    
    
    var totalSubscriptionsPrice: Double {
        return subscriptions.reduce(0) {  $0 + $1.price }
    }
    
    var theMostExpensiveSubscription: Subscription? {
        subscriptions.first(where: {$0.price == subscriptions.compactMap({$0.price}).max()})
    }
    
    var groupedByMonth: [GroupedByMonthSubscriptions] {
        
        var groupedByMonthSubscriptions: [GroupedByMonthSubscriptions] = []
        
        let groupDic = Dictionary(grouping: subscriptions) { (pendingCamera) -> DateComponents in
            let date = Calendar.current.dateComponents([.month], from: (pendingCamera.startDate))
            return date
        }
        
        groupDic.forEach { key, value in
            let g = GroupedByMonthSubscriptions(id: UUID(), month: key.month ?? 1, elemetns: value)
            groupedByMonthSubscriptions.append(g)
        }
        
        return groupedByMonthSubscriptions
    }
}

extension Calendar {
    func numberOf24DaysBetween(_ from: Date, and to: Date) -> Int {
        let numberOfDays = dateComponents([.day], from: from, to: to)
        
        return numberOfDays.day! + 1
    }
}

