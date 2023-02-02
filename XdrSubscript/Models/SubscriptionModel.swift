//
//  SubscriptionModel.swift
//  XdrSubscript
//
//  Created by Malovic, Milos on 18.11.22..
//

import Foundation

enum SubscriptionType: Int, Codable, CaseIterable {
    case yearly = 0
    case monthly = 1
    
    var text: String {
        switch self {
        case .monthly:
            return "/mo"
        case .yearly:
            return "/year"
        }
    }
}
