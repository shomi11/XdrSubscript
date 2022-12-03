//
//  SubscriptionListView.swift
//  XdrSubscript
//
//  Created by Malovic, Milos on 18.11.22..
//

import SwiftUI
import FirebaseFirestoreSwift
import FirebaseAuth
import Firebase
import RevenueCat

struct SubscriptionListView: View {
    
    @EnvironmentObject private var appState: AppState
    @State private var showNewSubscriptionView: Bool = false
    @State var user: User
    @State private var showLoader = false
    @State private var showPayWall: Bool = false
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
                            Section {
                                ForEach(user.isSubscriptionStatusActive ? filteredSubscriptions : Array(filteredSubscriptions.prefix(3)), id: \.uuid) { sub in
                                    NavigationLink {
                                        SubscriptionDetailsView(subcription: sub, user: user)
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
                        if appState.subscriptions.count < 3 || user.isSubscriptionStatusActive {
                            showNewSubscriptionView = true
                        } else {
                            showPayWall = true
                        }
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
                    user: user,
                    addedNewSubscription: $addedNewSubscription
                )
            })
            .fullScreenCover(isPresented: $showPayWall, onDismiss: {
                
            }, content: {
                PayWallView(user: user)
            })
            .onAppear {
                getSubscriptions()
                Purchases.shared.logIn(user.userID) { customerInfo, bool, error in
                    guard error == nil else { return }
                }
            }
        }
    }
    
    private func getSubscriptions() {
        showLoader = true
        let db = Firestore.firestore()
        let _ = db.collection("Users").document(user.userID).collection("subscriptions").getDocuments(completion: { snapShot, error in
            showLoader = false
            guard let docs = snapShot?.documents else { return }
            appState.subscriptions = docs.compactMap { snap -> Subscription? in
                do {
                    return try snap.data(as: Subscription.self)
                }
                catch {
                    print(error)
                    return nil
                }
            }
        })
    }
    
    func cellForSub(sub: Subscription) -> some View {
        HStack(alignment: .top, spacing: 16) {
            VStack(alignment: .leading, spacing: 8) {
                HStack(alignment: .bottom) {
                    Text("Subscribed to:")
                        .foregroundColor(.secondary)
                    Spacer()
                    Text(sub.name)
                        .fontWeight(.medium)
                }
                HStack(alignment: .bottom) {
                    Text("Start date:")
                        .foregroundColor(.secondary)
                    Spacer()
                    Text(DateFormatter.localizedString(from: sub.startDate, dateStyle: .medium, timeStyle: .none))
                        .fontWeight(.medium)
                }
                HStack(alignment: .center, spacing: 4) {
                    Spacer()
                    Text(sub.price.formatted(.currency(code: selectedCurrency)))
                        .fontWeight(.bold)
                        .foregroundColor(.red)
                    Text(sub.model.text)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding()
    }

}

struct SubscriptionListView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            SubscriptionListView(user: User.example)
                .environmentObject(AppState())
        }
    }
}

