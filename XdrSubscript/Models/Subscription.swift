//
//  Subscription.swift
//  XdrSubscript
//
//  Created by Malovic, Milos on 18.11.22..
//

import Foundation
import FirebaseFirestoreSwift
import Firebase

struct Subscription: Codable, Identifiable, Equatable, Comparable {
   
    static func < (lhs: Subscription, rhs: Subscription) -> Bool {
        rhs.price > lhs.price
    }
    
    init(uuid: String, name: String, startDate: Date, price: Double, model: SubscriptionModel) {
        self.name = name
        self.startDate = startDate
        self.price = price
        self.model = model
        self.uuid = uuid
    }
    
    @DocumentID var id: String?
    var uuid: String
    var name: String
    var startDate: Date
    var price: Double
    var model: SubscriptionModel
    
    static var subs: [Subscription] {
        var subs: [Subscription] = []
        for i in 0..<10 {
            let sub = Subscription(uuid: UUID().uuidString, name: "\(i)Subsctiption", startDate: Date(), price: 10.85, model: .monthly)
            subs.append(sub)
        }
        return subs
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.uuid, forKey: .uuid)
        try container.encode(self.name, forKey: .name)
        try container.encode(self.startDate, forKey: .startDate)
        try container.encode(self.price, forKey: .price)
        try container.encode(self.model, forKey: .model)
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(DocumentID<String>.self, forKey: .id).wrappedValue
        self.name = try container.decode(String.self, forKey: .name)
        self.startDate = try container.decode(Date.self, forKey: .startDate)
        self.price = try container.decode(Double.self, forKey: .price)
        self.model = try container.decode(SubscriptionModel.self, forKey: .model)
        self.uuid = try container.decode(String.self, forKey: .uuid)
    }
    
    enum CodingKeys: CodingKey {
        case id
        case name
        case startDate
        case price
        case model
        case uuid
    }

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
}

