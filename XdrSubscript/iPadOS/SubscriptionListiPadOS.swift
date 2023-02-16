//
//  SubscriptionListiPadOS.swift
//  XdrSubscript
//
//  Created by Malovic, Milos on 14.2.23..
//

import SwiftUI

struct SubscriptionListiPadOS: View {
    
    private enum SideBarCase: String, CaseIterable, Hashable {
        case Subscription
        case Info
        case History
        case Settings
        
        var systemImageName: String {
            switch self {
            case .Subscription:
                return "list.dash"
            case .Info:
                return "info"
            case .History:
                return "calendar.badge.clock"
            case .Settings:
                return "gear"
            }
        }
    }
    
    @State private var selectedNav: SideBarCase? = .Subscription
    
    var body: some View {
        NavigationSplitView {
            List(SideBarCase.allCases, id: \.self, selection: $selectedNav) { nav in
                NavigationLink(value: nav) {
                    Label(nav.rawValue, systemImage: nav.systemImageName)
                }
            }.navigationTitle("")
        } detail: {
            switch selectedNav {
            case .Subscription:
                SubscriptionListView()
            case .Info:
                InfoView()
            case .History:
                HistoryView()
            case .Settings:
                SettingsView()
            case .none:
                EmptyView()
            }
        }
    }
}

struct SubscriptionListiPadOS_Previews: PreviewProvider {
    static var previews: some View {
        SubscriptionListiPadOS()
    }
}
