//
//  SubscriptionListView.swift
//  XdrSubscript
//
//  Created by Malovic, Milos on 18.11.22..
//

import SwiftUI
import CoreData

struct SubscriptionListView: View {
    
    @Environment(\.managedObjectContext) var moc
    @EnvironmentObject private var appState: AppState
    @State private var showNewSubscriptionView: Bool = false
    @State private var showLoader = false
    @State private var searchTxt: String = ""
    @State private var addedNewSubscription = false
    
    var selectedCurrency = UserDefaults.standard.value(forKey: "selectedCurrency") as? String ?? "USD"
    @State var orderedBy = UserDefaults.standard.value(forKey: "sorted") as? SortedBy.RawValue ?? SortedBy.newest.rawValue
    
    var filteredSubscriptions: [Subscription] {
           if searchTxt.isEmpty {
               switch orderedBy {
               case SortedBy.byName.rawValue:
                   return appState.subscriptions.sorted(by: {$0.name < $1.name})
               case SortedBy.newest.rawValue:
                   return appState.subscriptions.sorted(by: {$0.startDate < $1.startDate})
               case SortedBy.oldest.rawValue:
                   return appState.subscriptions.sorted(by: {$0.startDate > $1.startDate})
               case SortedBy.byPriceAscending.rawValue:
                   return appState.subscriptions.sorted(by: {$0.price > $1.price})
               case SortedBy.byPriceDescending.rawValue:
                   return appState.subscriptions.sorted(by: {$0.price < $1.price})
               default:
                   return appState.subscriptions
               }
           } else {
               return appState.subscriptions.filter { $0.name.localizedCaseInsensitiveContains(searchTxt) }
           }
       }
    
    var body: some View {
        NavigationStack {
            Group {
                ZStack {
                    if !showLoader && appState.subscriptions.isEmpty {
                        EmptyView()
                    } else {
                        List {
                            
                            if let _ = appState.nextSub() {
                                nextSubcriptionView
                            }
                            
                            Section {
                                ForEach(filteredSubscriptions, id: \.id) { sub in
                                    NavigationLink {
                                        SubscriptionDetailsView(
                                            subcription: sub
                                        )
                                    } label: {
                                        cellForSub(sub: sub)
                                    }
                                }
                            } header: {
                                Text("Subscriptions")
                            }
                        }
                    }
                    if showLoader {
                        SpinnerView()
                    }
                }
            }
            .navigationTitle("Home")
            .searchable(text: $searchTxt, prompt: "Subcription Name")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showNewSubscriptionView = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
                ToolbarItem(placement: .navigationBarLeading) {
                    Menu {
                        ForEach(SortedBy.allCases, id: \.self.rawValue) { text in
                            Button {
                                orderedBy = text.rawValue
                            } label: {
                                HStack(alignment: .center, spacing: 8) {
                                    Text(text.text)
                                    if text.rawValue == orderedBy {
                                        Image(systemName: "checkmark")
                                    }
                                }
                            }
                        }
                    } label: {
                        Image(systemName: "arrow.up.arrow.down")
                    }
                }
            }
            .onChange(of: orderedBy) { newValue in
                UserDefaults.standard.set(newValue, forKey: "sorted")
            }
            .sheet(isPresented: $showNewSubscriptionView, onDismiss: {
                if addedNewSubscription {
                    addedNewSubscription = false
                    getSubscriptions()
                }
            }, content: {
                NewSubscriptionView(
                    addedNewSubscription: $addedNewSubscription
                )
            })
        }
    }
    
    private func getSubscriptions() {
        let fetch = Subscription.fetchRequest()
        fetch.sortDescriptors = []
        let results = (try? moc.fetch(fetch) as [Subscription]) ?? []
        appState.subscriptions = results
    }
    
    private func deleteSubscription(subcription: Subscription) {
        let object = moc.object(with: subcription.objectID)
        moc.delete(object)
        do {
            try moc.save()
        }
        catch {
            print("==== cant delete object")
        }
    }
    
    @ViewBuilder
    private var nextSubcriptionView: some View {
        Section {
            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack(alignment: .center, spacing: 8) {
                    ForEach(appState.nextSub() ?? [], id: \.id) { sub in
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
            Text("On the way next:")
        }
        .listRowBackground(Color.secondaryBackgroundColor)
    }
    
    func cellForSub(sub: Subscription) -> some View {
        HStack(alignment: .top, spacing: 16) {
            VStack(alignment: .leading, spacing: 8) {
                HStack(alignment: .bottom) {
                    Text("Subscribed to:")
                        .foregroundColor(.secondary)
                        .font(.body15)
                    Spacer()
                    Text(sub.name)
                        .fontWeight(.medium)
                        .font(.body15)
                }
                HStack(alignment: .bottom) {
                    Text("Start date:")
                        .font(.body14)
                        .foregroundColor(.secondary)
                    Spacer()
                    Text(DateFormatter.localizedString(from: sub.startDate, dateStyle: .medium, timeStyle: .none))
                        .fontWeight(.medium)
                        .font(.body14)
                }
                HStack(alignment: .center, spacing: 4) {
                    Text(sub.price.formatted(.currency(code: selectedCurrency)))
                        .fontWeight(.bold)
                        .foregroundColor(.red)
                        .font(.body14)
                    Text(sub.model.text)
                        .foregroundColor(.secondary)
                        .font(.body14)
                }
            }
        }
        .padding()
    }

}

struct SubscriptionListView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            SubscriptionListView()
                .environmentObject(AppState())
                .environmentObject(DataController())
        }
    }
}

extension Date {

    func fullDistance(from date: Date, resultIn component: Calendar.Component, calendar: Calendar = .current) -> Int? {
        calendar.dateComponents([component], from: self, to: date).value(for: component)
    }

    func distance(from date: Date, only component: Calendar.Component, calendar: Calendar = .current) -> Int {
        let days1 = calendar.component(component, from: self)
        let days2 = calendar.component(component, from: date)
        return days1 - days2
    }

    func hasSame(_ component: Calendar.Component, as date: Date) -> Bool {
        distance(from: date, only: component) == 0
    }
}

