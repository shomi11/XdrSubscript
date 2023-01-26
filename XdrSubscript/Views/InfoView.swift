//
//  InfoView.swift
//  XdrSubscript
//
//  Created by Malovic, Milos on 18.11.22..
//

import SwiftUI
import Charts

struct InfoView: View {
    
    @EnvironmentObject private var appState: AppState
    var selectedCurrency = UserDefaults.standard.value(forKey: "selectedCurrency") as? String ?? "USD"
    
    var body: some View {
        
        NavigationStack {
            Group {
                if !appState.subscriptions.isEmpty {
                    Form {
                        headerCardView
                        if let _ = appState.theMostExpensiveSubscription {
                            mostExpensiveView
                        }
                        recentsView
                        priceChartView
                        totalPaidHistoryPerSubscriptionChartView
                        numberOfMontsSubscriedChartView
                    }
                } else {
                    EmptyView()
                }
            }
            .background(content: {
                if !appState.subscriptions.isEmpty {
                    Color.secondaryBackgroundColor
                        .ignoresSafeArea()
                }
            })
            .navigationTitle("Subscriptions Info")
        }
    }
    
    private var headerCardView: some View {
        Section {
            VStack(alignment: .leading, spacing: 12) {
                HStack(alignment: .bottom) {
                    Text("Total subscription's price:")
                        .font(.body15)
                        .foregroundColor(.secondary)
                    Spacer()
                    Text(appState.totalSubscriptionsPrice.formatted(.currency(code: selectedCurrency)))
                        .font(.body15)
                        .fontWeight(.bold)
                        .foregroundColor(.red)
                }
                
                HStack(alignment: .bottom) {
                    Text("Total number of subscriptions's:")
                        .font(.body15)
                        .foregroundColor(.secondary)
                    Spacer()
                    Text("\(appState.subscriptions.count)")
                        .font(.body15)
                        .fontWeight(.bold)
                }
            }
        } header: {
            Text("Overview")
        }
    }
    
    @ViewBuilder
    private var mostExpensiveView: some View {
        if let mostExpensiveSub = appState.theMostExpensiveSubscription {
            Section {
                HStack(alignment: .bottom) {
                    Text(mostExpensiveSub.name)
                        .font(.body15)
                        .fontWeight(.bold)
                    Spacer()
                    Text(mostExpensiveSub.price.formatted(.currency(code: selectedCurrency)))
                        .font(.body15)
                        .fontWeight(.bold)
                }
            } header: {
                Text("The most expensive")
            }
        }
    }
    
    @ViewBuilder
    private var recentsView: some View {
        let sorted = appState.subscriptions.sorted(by: {$0.dateCreated > $1.dateCreated})
        let recents = Array(sorted.prefix(4))
        Section {
            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack(alignment: .center, spacing: 8) {
                    ForEach(recents, id: \.id) { sub in
                        VStack(alignment: .leading, spacing: 8) {
                            HStack(alignment: .center) {
                                Text(sub.name)
                                    .font(.body14)
                                Spacer()
                                Text(sub.price.formatted(.currency(code: selectedCurrency)))
                                    .font(.body14)
                                    .fontWeight(.medium)
                            }
                            Text(DateFormatter.localizedString(from: sub.startDate, dateStyle: .medium, timeStyle: .none))
                                .font(.body14)
                                .foregroundColor(.secondary)
                                .fontWeight(.light)
                            HStack(alignment: .center) {
                                Text(sub.notificationOn ? "Nofication on" : "Nofication off")
                                    .foregroundColor(.secondary)
                                    .fontWeight(.light)
                                    .font(.body15)
                                Image(systemName: "bell")
                                    .font(.body15)
                                    .fontWeight(.medium)
                                    .foregroundColor(sub.notificationOn ? .blue : .secondary)
                            }
                        }
                        .padding()
                        .background(Color.white)
                        .cornerRadius(12)
                    }
                }
            }
        } header: {
            Text("Recents")
        }
        .listRowBackground(Color.secondaryBackgroundColor)
    }
    
    private var priceChartView: some View {
        Section {
            VStack(alignment: .leading, spacing: 8) {
                Text("Price Chart")
                    .foregroundColor(.secondary)
                    .font(.caption)
                    .padding(.leading)
                Chart {
                    ForEach(appState.subscriptions.sorted(by: {$0.price > $1.price})) { sub in
                        BarMark(
                            x: .value("Name", sub.name),
                            y: .value("Total", sub.price.formatted(.currency(code: selectedCurrency)))
                        )
                    }
                }
            }
            .frame(height: 250)
        } header: {
            Text("By Price")
        }
    }
    
    private var totalPaidHistoryPerSubscriptionChartView: some View {
        Section {
            VStack(alignment: .leading, spacing: 8) {
                Text("Total paid per subcription")
                    .foregroundColor(.secondary)
                    .font(.caption)
                    .padding(.leading)
                Chart {
                    ForEach(appState.subscriptions, id: \.id) { sub in
                        BarMark(
                            x: .value("Name", sub.name),
                            y: .value("Total", sub.totalPaidTillNow)
                        )
                        .foregroundStyle(.indigo)
                    }
                }
            }
            .frame(height: 250)
        } header: {
            Text("Total per subcription")
        }
    }
    
    private var numberOfMontsSubscriedChartView: some View {
        Section {
            VStack(alignment: .leading, spacing: 8) {
                Text("Total number of months subcribed")
                    .foregroundColor(.secondary)
                    .font(.caption)
                    .padding(.leading)
                Chart {
                    ForEach(appState.subscriptions, id: \.id) { sub in
                        BarMark(
                            x: .value("Name", sub.name),
                            y: .value("Total", sub.numberOfMonthsSubscribed)
                        )
                        .foregroundStyle(.green)
                    }
                }
            }
            .frame(height: 250)
        } header: {
            Text("Number of months subcribed")
        }
    }
}

struct InfoView_Previews: PreviewProvider {
    static var previews: some View {
        InfoView()
            .environmentObject(AppState())
    }
}
