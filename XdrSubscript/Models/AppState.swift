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
    @Published var maxSpending = UserDefaults.standard.value(forKey: "max_spending") as? Double ?? 0.0
    @Published var userName = UserDefaults.standard.value(forKey: "userName") as? String ?? ""
    
    func nextSub() -> [DaysLeft]? {
        
        var daysLeftSubs: [DaysLeft] = []
        
        if !subscriptions.isEmpty {
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
                
                let dayLeft = Calendar.current.numberOf24DaysBetween(.now, and: nextMonth!)
                let d = DaysLeft.init(sub: subscription, daysLeft: dayLeft)
                daysLeftSubs.append(d)
            }
        }
        return daysLeftSubs
    }
    
    
    var totalSubscriptionsPriceMonthly: Double {
        return subscriptions.filter({$0.model == .monthly}).reduce(0) {  $0 + $1.price }
    }
    
    var totalSubscriptionsPriceYearly: Double {
        return subscriptions.filter({$0.model == .yearly}).reduce(0) {  $0 + $1.price }
    }
    
    var theMostExpensiveSubscription: Subscription? {
        subscriptions.first(where: {$0.price == subscriptions.compactMap({$0.montlyPrice}).max()})
    }
    
    var totalMonthlyAndYearlyPerMonth: Double {
        totalSubscriptionsPriceMonthly + (totalSubscriptionsPriceYearly / 12)
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

struct DaysLeft {
    let id = UUID()
    var sub: Subscription
    var daysLeft: Int
}

