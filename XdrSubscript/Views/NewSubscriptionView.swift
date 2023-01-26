//
//  NewSubscriptionView.swift
//  XdrSubscript
//
//  Created by Malovic, Milos on 21.11.22..
//

import SwiftUI
import UserNotifications

struct NewSubscriptionView: View {
    
    @Environment(\.managedObjectContext) var moc
    @Environment(\.dismiss) var dismiss
    @State private var newSubsriptionProviderName: String = ""
    @State private var startDate: Date = Date()
    @State private var price: Double = 0.00
    @State private var subscriptionModel: SubscriptionType = .monthly
    @State private var showSuccessView = false
    @Binding var addedNewSubscription: Bool
    @State private var setNotification: Bool = false
    var selectedCurrency = UserDefaults.standard.value(forKey: "selectedCurrency") as? String ?? "USD"
    
    var formater: NumberFormatter {
        let formater = NumberFormatter()
        formater.numberStyle = .decimal
        formater.currencySymbol = Locale.current.currencySymbol ?? selectedCurrency
        formater.currencyCode = selectedCurrency
        formater.formatWidth = 2
        return formater
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Form {
                    Section {
                        TextField("Name", text: $newSubsriptionProviderName)
                    } header: {
                        Text("Subscription Provider")
                    }
                    Section {
                        TextField("$0.00", value: $price, formatter: formater)
                            .keyboardType(.decimalPad)
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
                        Text("Notification reminder on the day of subscription should be billed")
                    }
                    
                }
                if showSuccessView {
                    SuccessView(title: "\(newSubsriptionProviderName) added to your subsription's.", message: "", showSelf: $showSuccessView)
                }
            }
            .navigationBarTitle("New Subscription")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        addSubscription()
                    } label: {
                        Text("Save")
                            .fontWeight(.medium)
                    }
                    .disabled(saveDisabled())
                }
                ToolbarItem(placement: .navigationBarLeading) {
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
                content.subtitle = "\(selectedCurrency) \(price)"
                content.sound = UNNotificationSound.default
                
                var components = Calendar.current.dateComponents([.weekday, .day], from: startDate)
                components.hour = 10
                
                let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)

                let request = UNNotificationRequest(identifier: newSub.id.uuidString, content: content, trigger: trigger)

                UNUserNotificationCenter.current().add(request)
            }
            showSuccessView = true
        } catch {
            print(error)
        }
    }
}

struct NewSubscriptionView_Previews: PreviewProvider {
    static var previews: some View {
        NewSubscriptionView(addedNewSubscription: .constant(false))
            .environmentObject(DataController())
    }
}


extension Date {
    
    var weekday: Int {
        return Calendar.current.component(.weekday, from: self)
    }
    
    var day: Int {
        return Calendar.current.component(.day, from: self)
    }
    
    var hour: Int {
        return Calendar.current.component(.hour, from: self)
    }
    
    
}
