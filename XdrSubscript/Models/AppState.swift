//
//  AppState.swift
//  XdrSubscript
//
//  Created by Malovic, Milos on 23.11.22..
//

import Foundation


class AppState: ObservableObject {
    @Published var subscriptions: [Subscription] = []
    
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
