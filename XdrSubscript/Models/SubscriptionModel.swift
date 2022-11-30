//
//  SubscriptionModel.swift
//  XdrSubscript
//
//  Created by Malovic, Milos on 18.11.22..
//

import Foundation

enum SubscriptionModel: String, Codable, CaseIterable {
    case yearly
    case monthly
    
    var text: String {
        switch self {
        case .monthly:
            return "per month"
        case .yearly:
            return "per year"
        }
    }
}
