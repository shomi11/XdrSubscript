//
//  GroupedByMonthSubscriptions.swift
//  XdrSubscript
//
//  Created by Malovic, Milos on 24.11.22..
//

import Foundation


struct GroupedByMonthSubscriptions {
    
    var id = UUID()
    var month: Int
    var elemetns: [Subscription]
    
    var monthTxt: String {
        switch month {
        case 1:
            return "Jan"
        case 2:
            return "Feb"
        case 3:
            return "March"
        case 4:
            return "April"
        case 5:
            return "May"
        case 6:
            return "June"
        case 7:
            return "July"
        case 8:
            return "Aug"
        case 9:
            return "Sep"
        case 10:
            return "Oct"
        case 11:
            return "Nov"
        case 12:
            return "Dec"
        default:
            return ""
        }
    }
}
