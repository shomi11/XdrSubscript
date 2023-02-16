//
//  SubscriptionListView.swift
//  XdrSubscript
//
//  Created by Malovic, Milos on 18.11.22..
//

import SwiftUI
import CoreData
import CloudKit
import CoreSpotlight
import WidgetKit

struct SubscriptionListView: View {
    
    @Environment(\.horizontalSizeClass) var horizontalSizeClass: UserInterfaceSizeClass?
    @Environment(\.verticalSizeClass) var verticalSizeClass: UserInterfaceSizeClass?
    @Environment(\.managedObjectContext) var moc
    @EnvironmentObject private var appState: AppState
    @State private var showNewSubscriptionView: Bool = false
    @State private var searchTxt: String = ""
    @State private var addedNewSubscription = false
    @State private var showSpendingDetailsFullCard: Bool = false
    @State private var selectedSub: Subscription?
    @State private var path: [Subscription] = []
    
    @State var orderedBy = UserDefaults.standard.value(forKey: "sorted") as? SortedBy.RawValue ?? SortedBy.newest.rawValue
    
    var filteredSubscriptions: [Subscription] {
           if searchTxt.isEmpty {
               switch orderedBy {
               case SortedBy.byName.rawValue:
                   return appState.subscriptions.filter({$0.movedToHistory == false}).sorted(by: {$0.name < $1.name})
               case SortedBy.newest.rawValue:
                   return appState.subscriptions.filter({$0.movedToHistory == false}).sorted(by: {$0.dateCreated > $1.dateCreated})
               case SortedBy.oldest.rawValue:
                   return appState.subscriptions.filter({$0.movedToHistory == false}).sorted(by: {$0.dateCreated < $1.dateCreated})
               case SortedBy.byPriceAscending.rawValue:
                   return appState.subscriptions.filter({$0.movedToHistory == false}).sorted(by: {$0.price > $1.price})
               case SortedBy.byPriceDescending.rawValue:
                   return appState.subscriptions.filter({$0.movedToHistory == false}).sorted(by: {$0.price < $1.price})
               default:
                   return appState.subscriptions.filter({$0.movedToHistory == false})
               }
           } else {
               return appState.subscriptions.filter({$0.movedToHistory == false}).filter { $0.name.localizedCaseInsensitiveContains(searchTxt) }
           }
       }
    
    var body: some View {
        NavigationStack(path: $path) {
            Group {
                ZStack {
                    switch appState.loadingState {
                    case .loading:
                        ProgressView()
                            .progressViewStyle(.circular)
                            .tint(.indigo)
                    case .empty:
                        EmptyListView(showNewSubscriptionView: $showNewSubscriptionView)
                    case .none:
                        List {
                            if let _ = appState.nextSub() {
                                nextSubcriptionView
                            }
                            if appState.maxSpending != 0.0 {
                                maxSpendingView
                            }
                            if horizontalSizeClass == .regular && verticalSizeClass == .regular {
                                iPadOSsectionListView
                            } else {
                                iOSsectionListView
                            }
                        }
                        .listStyle(.plain)
                        .scrollContentBackground(.hidden)
                        .background {
                            BackgroundView()
                        }
                    }
                }
            }
            .navigationTitle(appState.userName.isEmpty ? "Hello" : "Hello, \(appState.userName)")
            .navigationDestination(for: Subscription.self, destination: { sub in
                SubscriptionDetailsView(subcription: sub)
            })
            .searchable(text: $searchTxt, prompt: "Subscription Name")
            .onContinueUserActivity(CSSearchableItemActionType, perform: loadSpotLightSubscription)
            .onOpenURL(perform: { url in
                showNewSubscriptionView = true
            })
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        showNewSubscriptionView = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
                ToolbarItem(placement: .cancellationAction) {
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
            .fullScreenCover(isPresented: $showNewSubscriptionView, onDismiss: {
                if addedNewSubscription {
                    addedNewSubscription = false
                    Task {
                        await getSubscriptions()
                    }
                }
            }, content: {
                NewSubscriptionView(
                    addedNewSubscription: $addedNewSubscription
                )
            })
            .sheet(item: $selectedSub, onDismiss: {
                selectedSub = nil
            }, content: { sub in
                NavigationStack {
                    SubscriptionDetailsView(subcription: sub)
                        .navigationTitle(sub.name)
                }
            })
            .task {
                let status = await accountStatus()
                if status == .available {
                    await getSubscriptions()
                }
            }
        }
    }
    
    private var iPadOSsectionListView: some View {
        Section {
            let columns = [
                GridItem(.adaptive(minimum: 300, maximum: 400))
            ]
            LazyVGrid(columns: columns, alignment: .leading, spacing: 16) {
                ForEach(filteredSubscriptions, id: \.id) { sub in
                    Button {
                        selectedSub = sub
                    } label: {
                        cellForSub(sub: sub)
                    }
                }
            }
        } header: {
            Text("Subscriptions".uppercased())
                .font(.title3)
                .fontWeight(.semibold)
                .fontDesign(.rounded)
                .foregroundColor(.primary)
        }
        .listRowSeparator(.hidden)
        .listSectionSeparator(.hidden)
        .listRowBackground(Color.clear)
    }
    
    private var iOSsectionListView: some View {
        Section {
            ForEach(filteredSubscriptions, id: \.id) { sub in
                if horizontalSizeClass == .regular && verticalSizeClass == .regular {
                    Button {
                        selectedSub = sub
                    } label: {
                        cellForSub(sub: sub)
                    }
                } else {
                    NavigationLink(value: sub) {
                        cellForSub(sub: sub)
                    }
                }
            }
        } header: {
            Text("Subscriptions".uppercased())
                .font(.title3)
                .fontWeight(.semibold)
                .fontDesign(.rounded)
                .foregroundColor(.primary)
        }
        .listRowSeparator(.hidden)
        .listSectionSeparator(.hidden)
        .listRowBackground(Color.clear)
    }
    
    func accountStatus() async -> CKAccountStatus {
        let container = CKContainer.default()
        let status = try? await container.accountStatus()
        return status ?? .couldNotDetermine
    }
    
    private func getSubscriptions() async {
        appState.loadingState = .loading
         moc.performAndWait({
            let fetch = Subscription.fetchRequest()
            fetch.sortDescriptors = []
            fetch.resultType = .managedObjectResultType
            if let results = (try? moc.fetch(fetch) as [Subscription]), results.isEmpty == false {
                appState.subscriptions = results
                if results.isEmpty {
                    appState.loadingState = .empty
                } else {
                    if results.filter({$0.movedToHistory == false}).isEmpty {
                        appState.loadingState = .empty
                    } else {
                        appState.loadingState = .none
                    }
                }
            } else {
                appState.loadingState = .empty
            }
             WidgetCenter.shared.reloadAllTimelines()
        })
    }
 
    private var maxSpendingView: some View {
        Section {
            VStack(alignment: .leading, spacing: 16) {
                VStack(alignment: .leading, spacing: 4) {
                    HStack(alignment: .top) {
                        Text("Spending Status")
                        Spacer()
                        Button {
                            withAnimation {
                                showSpendingDetailsFullCard.toggle()
                            }
                        } label: {
                            Image(systemName: "chevron.down")
                                .bold()
                                .foregroundColor(.indigo)
                        }
                    }
                    VStack(alignment: .leading, spacing: 8) {
                        ProgressView(
                            value: Float(appState.totalMonthlyAndYearlyPerMonth),
                            total: Float(appState.maxSpending)
                        )
                            .progressViewStyle(.linear)

                        if appState.maxSpending > appState.totalSubscriptionsPriceMonthly {
                            let stillHave = appState.totalMonthlyAndYearlyPerMonth - appState.maxSpending
                            Text(!appState.userName.isEmpty ? "\(appState.userName), you are \(stillHave.formatted(.currency(code: appState.selectedCurrency))) bellow max" : "You are \(stillHave.formatted(.currency(code: appState.selectedCurrency))) bellow max")
                                .font(.caption)
                                .foregroundColor(.primary.opacity(0.8))
                        } else {
                            let minus = appState.totalMonthlyAndYearlyPerMonth - appState.maxSpending
                            Text(!appState.userName.isEmpty ? "\(appState.userName), you are \(minus.formatted(.currency(code: appState.selectedCurrency))) above max" : "You are \(minus.formatted(.currency(code: appState.selectedCurrency))) above max")
                                .font(.caption)
                                .foregroundColor(.primary.opacity(0.8))
                        }
                    }
                }
                if showSpendingDetailsFullCard {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Monthly subcriptions total: \(appState.totalSubscriptionsPriceMonthly.formatted(.currency(code: appState.selectedCurrency)))")
                            .font(.caption)
                            .foregroundColor(.primary.opacity(0.8))
                        Text("Yearly Subcriptions total: \(appState.totalSubscriptionsPriceYearly.formatted(.currency(code: appState.selectedCurrency)))")
                            .font(.caption)
                            .foregroundColor(.primary.opacity(0.8))
                        Text("All subcription per month: \(appState.totalMonthlyAndYearlyPerMonth.formatted(.currency(code: appState.selectedCurrency)))")
                            .font(.caption)
                            .foregroundColor(.primary.opacity(0.8))
                    }
                    .transition(.scale)
                }
            }
            .listRowBackground(Color.clear)
            .padding()
            .background(Color.systemBackgroundColor.opacity(0.5))
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        }
    }
    
    func loadSpotLightSubscription(_ activity: NSUserActivity) {
        if let identifier = activity.userInfo?[CSSearchableItemActivityIdentifier] as? String {
            if let sub = appState.convertSpotLightItemToSubscription(identifier, context: moc) {
                if sub.movedToHistory == false {
                    path.append(sub)
                }
            }
        }
    }
    
    @ViewBuilder
    private var nextSubcriptionView: some View {
        Section {
            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack(alignment: .center, spacing: 16) {
                    ForEach(appState.nextSub()?.filter({$0.sub.model == .monthly}) ?? [], id: \.id) { tupple in
                        VStack(alignment: .leading, spacing: 8) {
                            HStack(alignment: .center) {
                                Text(tupple.sub.name)
                                    .font(.body15)
                                    .fontWeight(.bold)
                                    .foregroundColor(.primary.opacity(0.7))
                                Spacer()
                                Text(tupple.sub.price.formatted(.currency(code: appState.selectedCurrency)))
                                    .font(.body15)
                                    .fontWeight(.bold)
                                    .foregroundColor(.primary.opacity(0.7))
                            }
                            Text("\(tupple.daysLeft) day(s) left")
                                .font(.body14)
                                .fontWeight(.medium)
                                .foregroundColor(.primary.opacity(0.7))
                            HStack(alignment: .center) {
                                Text(tupple.sub.notificationOn ? "Notification on" : "Notification off")
                                    .font(.body14)
                                    .fontWeight(.medium)
                                    .foregroundColor(.primary.opacity(0.7))
                                Image(systemName: tupple.sub.notificationOn ? "bell.fill" : "bell")
                                    .font(.body14)
                                    .fontWeight(.medium)
                                    .foregroundColor(tupple.sub.notificationOn ? .indigo : .secondary)
                            }
                        }
                        .padding()
                        .background(Color.systemBackgroundColor.opacity(0.5))
                        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                    }
                }
                .padding(.vertical, 6)
                .padding(.trailing, 4)
                .padding(.leading, 8)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical)
            
        } header: {
            Text("On the way next".uppercased())
                .font(.title3)
                .fontWeight(.semibold)
                .fontDesign(.rounded)
                .foregroundColor(.primary)
        }
        .listRowSeparator(.hidden)
        .listSectionSeparator(.hidden)
        .listRowBackground(Color.clear)
    }
    
    func cellForSub(sub: Subscription) -> some View {
        HStack(alignment: .top, spacing: 16) {
            if let url = URL(string: "https://logo.clearbit.com/\(sub.imageUrl)") {
                AsyncImage(url: url) { image in
                    image
                        .resizable()
                        .scaledToFit()
                        .frame(width: 50, height: 50, alignment: .center)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                } placeholder: {
                    if let letter = sub.name.first {
                        ZStack(alignment: .center) {
                            Circle()
                                .fill(Color.blue.opacity(0.4))
                                .frame(width: 50, height: 50, alignment: .center)
                            Text(String(letter))
                                .font(.title2)
                                .bold()
                        }
                    }
                }
            }
            VStack(alignment: .leading, spacing: 8) {
                HStack(alignment: .bottom) {
                    Text("Subscribed to:")
                        .foregroundColor(.secondary)
                        .font(.body15)
                    Spacer()
                    Text(sub.name)
                        .fontWeight(.medium)
                        .font(.body15)
                        .foregroundColor(.primary.opacity(0.7))
                }
                HStack(alignment: .bottom) {
                    Text("Start date:")
                        .font(.body14)
                        .foregroundColor(.secondary)
                        .foregroundColor(.primary.opacity(0.7))
                    Spacer()
                    Text(DateFormatter.localizedString(from: sub.startDate, dateStyle: .medium, timeStyle: .none))
                        .fontWeight(.medium)
                        .font(.body14)
                        .foregroundColor(.primary.opacity(0.7))
                }
                HStack(alignment: .center, spacing: 2) {
                    Text(sub.price.formatted(.currency(code: appState.selectedCurrency)))
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
        .background(Color.systemBackgroundColor.opacity(0.5))
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
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

