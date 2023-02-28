//
//  NewSubscriptionView.swift
//  XdrSubscript
//
//  Created by Malovic, Milos on 21.11.22..
//

import SwiftUI
import UserNotifications
import CloudKit
import BackgroundTasks

struct NewSubscriptionView: View {
    
    @Environment(\.managedObjectContext) private var moc
    @EnvironmentObject private var appState: AppState
    @Environment(\.dismiss) private var dismiss
    @State private var newSubsriptionProviderName: String = ""
    @State private var startDate: Date = Date()
    @State private var trialPeriodEnds: Date = Date()
    @State private var isTrialPeriod: Bool = false
    @State private var price: Double = 0.00
    @State private var subscriptionModel: SubscriptionType = .monthly
    @State private var showSuccessView = false
    @Binding var addedNewSubscription: Bool
    @State private var setNotification: Bool = false
    @State private var imageUrl: String = ""
    
    var formater: NumberFormatter {
        let formater = NumberFormatter()
        formater.numberStyle = .decimal
        formater.currencySymbol = Locale.current.currencySymbol ?? appState.selectedCurrency
        formater.currencyCode = appState.selectedCurrency
        formater.formatWidth = 2
        return formater
    }
    
    var body: some View {
        ZStack(alignment: .top) {
            NavigationStack {
                Form {
                    Section {
                        TextField("Name", text: $newSubsriptionProviderName)
                    } header: {
                        Text("Subscription Provider")
                    }
                    
                    Section {
                        VStack(alignment: .leading, spacing: 6) {
                            Toggle("Trial period", isOn: $isTrialPeriod)
                            if isTrialPeriod {
                                DatePicker("Trial end date", selection: $trialPeriodEnds, displayedComponents: .date)
                            }
                        }
                    } footer: {
                        Text("If you activate trial period, app will notify you day before trial expired.")
                    }
                    
                    Section {
                        TextField("$0.00", value: $price, formatter: formater)
                             #if os(iOS)
                            .keyboardType(.decimalPad)
                             #endif
                    } header: {
                        Text("$ Subscription Price")
                    }
                    Section {
                        Picker("Subscription Model", selection: $subscriptionModel) {
                            ForEach(SubscriptionType.allCases, id: \.self) { model in
                                Text(model.text)
                            }
                        }
                        .pickerStyle(.segmented)
                    }
                    Section {
                        DatePicker("Start Date", selection: $startDate, displayedComponents: .date)
                    }
                    Section {
                        VStack {
                            Toggle("Notification", isOn: $setNotification)
                        }
                    } footer: {
                        Text("Notification on the day of subscription should be billed")
                    }
                    Section {
                        TextField("youtube.com", text: $imageUrl)
                    } footer: {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("This is used for displaying subscription provider logo.")
                            HStack(alignment: .center, spacing: 4) {
                                Text("Provided by")
                                Link("Clearbit", destination: URL(string: "https://clearbit.com")!)
                                    .foregroundColor(.blue)
                                    .underline()
                            }
                        }
                    }
                }
                .navigationTitle("New Subscription")
                .toolbar {
                    ToolbarItem(placement: .primaryAction) {
                        Button {
                            addSubscription()
                        } label: {
                            Text("Save")
                                .fontWeight(.medium)
                        }
                        .disabled(saveDisabled())
                    }
                    ToolbarItem(placement: .cancellationAction) {
                        Button {
                            dismiss()
                        } label: {
                            Image(systemName: "xmark")
                        }
                    }
                }
                .onChange(of: showSuccessView, perform: { newValue in
                    if newValue == false {
                        addedNewSubscription = true
                        dismiss()
                    }
                })
            }
            DynamicIslandSuccessView(
                providerName: $newSubsriptionProviderName,
                providerPrice: $price,
                showSelf: $showSuccessView
            )
            .ignoresSafeArea()
        }
    }
    
    private func saveDisabled() -> Bool {
        if newSubsriptionProviderName.isEmpty {
            return true
        } else {
            return false
        }
    }
    
    private func addSubscription() {
        guard newSubsriptionProviderName.isEmpty == false else { return }
        let newSub = Subscription.init(context: moc)
        newSub.id = UUID()
        newSub.price = price
        newSub.name = newSubsriptionProviderName
        newSub.notificationOn = setNotification
        newSub.startDate = startDate
        newSub.dateCreated = Date()
        newSub.imageUrl = imageUrl
        newSub.movedToHistory = false
        newSub.dateMovedToHistory = Date()
        if isTrialPeriod {
            newSub.trialActivated = true
            newSub.trialEndDate = trialPeriodEnds
        }
        if subscriptionModel == .yearly {
            newSub.type = 0
        } else {
            newSub.type = 1
        }
        do {
            try moc.save()
            if setNotification {

                let content = UNMutableNotificationContent()
                content.title = newSubsriptionProviderName
                content.subtitle = "\(appState.selectedCurrency) \(price)"
                content.sound = UNNotificationSound.default

                var components = Calendar.current.dateComponents([.day], from: startDate)
                components.hour = 8
                components.minute = 0
                let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)

                let request = UNNotificationRequest(identifier: newSub.id.uuidString, content: content, trigger: trigger)

                UNUserNotificationCenter.current().add(request)
            }
           
            if isTrialPeriod {
                let content = UNMutableNotificationContent()
                content.title = newSubsriptionProviderName
                content.subtitle = "Trial period end tommorow"
                content.sound = UNNotificationSound.default
                var components = Calendar.current.dateComponents([.month, .year], from: trialPeriodEnds)
                components.day = trialPeriodEnds.day - 1
                components.hour = 8
                components.minute = 0
                let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
                let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
                UNUserNotificationCenter.current().add(request)
            }
            
            showSuccessView = true
            appState.addSubscriptionToSpotlight(newSub)
        } catch {
            print(error)
        }
    }
}

struct NewSubscriptionView_Previews: PreviewProvider {
    static var previews: some View {
        NewSubscriptionView(addedNewSubscription: .constant(false))
            .environmentObject(DataController())
            .environmentObject(AppState())
    }
}
