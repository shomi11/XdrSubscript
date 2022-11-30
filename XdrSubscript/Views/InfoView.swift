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
                    ScrollView(showsIndicators: false) {
                        headerCardView
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
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .bottom) {
                Text("Total subscription's price:")
                    .foregroundColor(.secondary)
                Spacer()
                Text(appState.totalSubscriptionsPrice.formatted(.currency(code: selectedCurrency)))
                    .fontWeight(.bold)
                    .font(.title2)
                    .foregroundColor(.red)
            }
            
            HStack(alignment: .bottom) {
                Text("Total number of subscriptions's:")
                    .foregroundColor(.secondary)
                Spacer()
                Text("\(appState.subscriptions.count)")
                    .fontWeight(.bold)
                    .font(.title2)
            }
            
            if let mostExpensiveSub = appState.theMostExpensiveSubscription {
                HStack(alignment: .bottom) {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("The most expensive:")
                            .foregroundColor(.secondary)
                        Text(mostExpensiveSub.name)
                    }
                    Spacer()
                    Text(mostExpensiveSub.price.formatted(.currency(code: selectedCurrency)))
                        .fontWeight(.bold)
                        .font(.title2)
                }
            }
        }
        .padding()
        .background(content: {
            Color.systemBackgroundColor
                .cornerRadius(12)
                .shadow(radius: 4)
        })
        .padding()
    }
    
    private var priceChartView: some View {
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
        .padding(.bottom)
    }
    
    private var totalPaidHistoryPerSubscriptionChartView: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Total paid per subcription")
                .foregroundColor(.secondary)
                .font(.caption)
                .padding(.leading)
            Chart {
                ForEach(appState.subscriptions) { sub in
                    BarMark(
                        x: .value("Name", sub.name),
                        y: .value("Total", sub.totalPaidTillNow)
                    )
                    .foregroundStyle(.indigo)
                }
            }
        }
        .frame(height: 250)
        .padding(.bottom)
    }
    
    private var numberOfMontsSubscriedChartView: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Total number of months subcribed")
                .foregroundColor(.secondary)
                .font(.caption)
                .padding(.leading)
            Chart {
                ForEach(appState.subscriptions) { sub in
                    BarMark(
                        x: .value("Name", sub.name),
                        y: .value("Total", sub.numberOfMonthsSubscribed)
                    )
                    .foregroundStyle(.green)
                }
            }
        }
        .frame(height: 250)
        .padding(.bottom)
    }
}

struct InfoView_Previews: PreviewProvider {
    static var previews: some View {
        InfoView()
            .environmentObject(AppState())
    }
}
