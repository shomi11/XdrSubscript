//
//  SortedBy.swift
//  XdrSubscript
//
//  Created by Malovic, Milos on 24.11.22..
//

import Foundation

enum SortedBy: String, CaseIterable {
    
    case byName
    case byPriceDescending
    case byPriceAscending
    case newest
    case oldest
    
    var text: String {
        switch self {
        case .byName:
            return "By Name"
        case .byPriceDescending:
            return "By Price Descending"
        case .byPriceAscending:
            return "By Price Ascending"
        case .newest:
            return "Newest"
        case .oldest:
            return "Oldest"
        }
    }
}
