//
//  Subscription+CoreDataClass.swift
//  XdrSubscript
//
//  Created by Malovic, Milos on 24.1.23..
//
//

import Foundation
import CoreData

@objc(Subscription)
public class Subscription: NSManagedObject {

    
    var priceTxt: String {
        let simbol = Locale.current.currencySymbol ?? "$"
        return "\(simbol)\(price)"
    }
    
    var totalPaidTillNow: Double {
        let diffs = Calendar.current.dateComponents([.month], from: startDate, to: Date())
        guard let monthCount = diffs.month, monthCount > 0 else { return price }
        let total = price * Double(monthCount)
        print(total)
        return total
    }
    
    var numberOfMonthsSubscribed: Int {
        let diffs = Calendar.current.dateComponents([.month], from: startDate, to: Date())
        guard let monthCount = diffs.month, monthCount > 0 else { return 1 }
        return monthCount
    }
    
    var model: SubscriptionType {
        if self.type == 1 {
            return .monthly
        } else {
            return .yearly
        }
    }
}
