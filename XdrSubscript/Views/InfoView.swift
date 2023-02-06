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
    @Environment(\.colorScheme) var colorScheme
    @State private var newSubscriptionView: Bool = false
    
    var body: some View {
        NavigationStack {
            Group {
                if !appState.subscriptions.filter({$0.movedToHistory == false}).isEmpty {
                    List {
                        headerCardView
                        if let _ = appState.theMostExpensiveSubscription {
                            mostExpensiveView
                        }
                        recentsView
                        priceChartView
                        totalPaidHistoryPerSubscriptionChartView
                        numberOfMontsSubscriedChartView
                    }
                    .listStyle(.plain)
                    .scrollContentBackground(.hidden)
                    .background {
                        BackgroundView()
                    }
                } else {
                    EmptyListView(showNewSubscriptionView: $newSubscriptionView)
                }
            }
            .navigationTitle("Subscriptions Info")
            .sheet(isPresented: $newSubscriptionView) {
                
            } content: {
                NewSubscriptionView(addedNewSubscription: .constant(false))
            }
        }
    }
    
    private var headerCardView: some View {
        Section {
            VStack(alignment: .leading, spacing: 12) {
                HStack(alignment: .bottom) {
                    Text("Total subscription's price:")
                        .font(.body15)
                        .foregroundColor(.primary.opacity(0.7))
                    Spacer()
                    Text(appState.totalMonthlyAndYearlyPerMonth.formatted(.currency(code: appState.selectedCurrency)))
                        .font(.body15)
                        .fontWeight(.bold)
                        .foregroundColor(.red)
                }
                
                HStack(alignment: .bottom) {
                    Text("Total number of subscriptions's:")
                        .font(.body15)
                        .foregroundColor(.primary.opacity(0.7))
                    Spacer()
                    Text("\(appState.subscriptions.count)")
                        .font(.body15)
                        .fontWeight(.bold)
                        .foregroundColor(.primary.opacity(0.7))
                }
            }
            .padding()
            .background(Color.systemBackgroundColor.opacity(0.5))
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        } header: {
            Text("Overview")
                .font(.title3)
                .fontDesign(.rounded)
                .foregroundColor(.primary)
                .bold()
        }
        .listRowBackground(Color.clear)
        .listRowSeparator(.hidden)
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
                    Text(mostExpensiveSub.price.formatted(.currency(code: appState.selectedCurrency)))
                        .font(.body15)
                        .fontWeight(.bold)
                        .foregroundColor(.red)
                }
                .padding()
                .background(Color.systemBackgroundColor.opacity(0.5))
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            } header: {
                Text("The most expensive(per month)")
                    .font(.title3)
                    .fontDesign(.rounded)
                    .foregroundColor(.primary)
                    .bold()
            }
            .listRowBackground(Color.clear)
            .listRowSeparator(.hidden)
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
                                Text(sub.price.formatted(.currency(code: appState.selectedCurrency)))
                                    .font(.body14)
                                    .fontWeight(.medium)
                            }
                            Text(DateFormatter.localizedString(from: sub.startDate, dateStyle: .medium, timeStyle: .none))
                                .font(.body14)
                                .foregroundColor(.primary.opacity(0.7))
                                .fontWeight(.light)
                            HStack(alignment: .center) {
                                Text(sub.notificationOn ? "Nofication on" : "Nofication off")
                                    .foregroundColor(.primary.opacity(0.7))
                                    .fontWeight(.light)
                                    .font(.body15)
                                Image(systemName: sub.notificationOn ? "bell.fill" : "bell")
                                    .font(.body15)
                                    .fontWeight(.medium)
                                    .foregroundColor(sub.notificationOn ? .indigo : .secondary)
                            }
                        }
                        .padding()
                        .background(Color.systemBackgroundColor.opacity(0.5))
                        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                    }
                }
            }
            .frame(maxWidth: .infinity)
        } header: {
            Text("Recents")
                .font(.title3)
                .fontDesign(.rounded)
                .foregroundColor(.primary)
                .bold()
        }
        .listRowBackground(Color.clear)
        .listRowSeparator(.hidden)
    }
    
    private var priceChartView: some View {
        Section {
            VStack(alignment: .leading, spacing: 8) {
                Text("Price Chart")
                    .foregroundColor(.secondary)
                    .font(.caption)
                    .padding(.leading)
                Chart {
                    ForEach(appState.subscriptions.sorted(by: {$0.montlyPrice > $1.montlyPrice})) { sub in
                        BarMark(
                            x: .value("Name", sub.name),
                            y: .value("Total", sub.montlyPrice.formatted(.currency(code: appState.selectedCurrency)))
                        )
                        .foregroundStyle(.orange)
                    }
                }
            }
            .padding()
            .frame(height: 250)
            .background(Color.systemBackgroundColor.opacity(0.5))
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        } header: {
            Text("By Price(monthly)")
                .font(.title3)
                .fontDesign(.rounded)
                .foregroundColor(.primary)
                .bold()
        }
        .listRowBackground(Color.clear)
        .listRowSeparator(.hidden)
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
            .padding()
            .frame(height: 250)
            .background(Color.systemBackgroundColor.opacity(0.5))
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        } header: {
            Text("Total per subcription")
                .font(.title3)
                .fontDesign(.rounded)
                .foregroundColor(.primary)
                .bold()
        }
        .listRowBackground(Color.clear)
        .listRowSeparator(.hidden)
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
            .padding()
            .frame(height: 250)
            .background(Color.systemBackgroundColor.opacity(0.5))
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        } header: {
            Text("Number of months subcribed")
                .font(.title3)
                .fontDesign(.rounded)
                .foregroundColor(.primary)
                .bold()
        }
        .listRowBackground(Color.clear)
        .listRowSeparator(.hidden)
    }
}

struct InfoView_Previews: PreviewProvider {
    static var previews: some View {
        InfoView()
            .environmentObject(AppState())
    }
}
