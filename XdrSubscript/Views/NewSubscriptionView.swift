//
//  NewSubscriptionView.swift
//  XdrSubscript
//
//  Created by Malovic, Milos on 21.11.22..
//

import SwiftUI
import FirebaseAuth
import FirebaseFirestoreSwift
import Firebase
import UserNotifications

struct NewSubscriptionView: View {
    
    @Environment(\.dismiss) var dismiss
    @State private var newSubsriptionProviderName: String = ""
    @State private var startDate: Date = Date()
    @State private var price: Double = 0.00
    @State private var subscriptionModel: SubscriptionModel = .monthly
    @State private var db = Firestore.firestore()
    @State var user: User
    @State private var showAlert = false
    @State private var errorMessage: String = ""
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
                    } header: {
                        Text("$ Subscription Price")
                            .keyboardType(.numberPad)
                    }
                    
                    Section {
                        Picker("Subscription Model", selection: $subscriptionModel) {
                            ForEach(SubscriptionModel.allCases, id: \.self) { model in
                                Text(model.text)
                            }
                        }
                        .pickerStyle(.segmented)
                    }
                    
                    Section {
                        DatePicker("Start Date", selection: $startDate, displayedComponents: .date)
                    }
                    
                    Section {
                        Toggle("Notification", isOn: $setNotification)
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
            .alert(errorMessage, isPresented: $showAlert) {
                Button.init("OK", role: .cancel, action: {})
            }
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
        
        let subscription = Subscription(uuid: UUID().uuidString, name: newSubsriptionProviderName, startDate: startDate, price: price, model: subscriptionModel)
        
        do {
            let _ = try db.collection("Users").document(user.userID).collection("subscriptions").addDocument(from: subscription, completion: { error in
                if let error = error {
                    errorMessage = error.localizedDescription
                    showAlert = true
                } else {
                    if setNotification {
                        let content = UNMutableNotificationContent()
                        content.title = "\(newSubsriptionProviderName)"
                        content.body = "\(price.formatted(.currency(code: selectedCurrency)))"
                    
                        var dateComponents = DateComponents()
                        dateComponents = Calendar.current.dateComponents([.weekOfMonth, .weekday, .day], from: startDate)
                        dateComponents.hour = 10
                           
                        let trigger = UNCalendarNotificationTrigger(
                                 dateMatching: dateComponents, repeats: true)
                        
                        let request = UNNotificationRequest(identifier: newSubsriptionProviderName,
                                    content: content, trigger: trigger)

                        let notificationCenter = UNUserNotificationCenter.current()
                        notificationCenter.add(request) { (error) in
                           if error != nil {
                              // Handle any errors.
                           } else {
                               print("notification scheduled succes")
                           }
                        }
                    }
                   showSuccessView = true
                }
            })
        }
        catch {
            errorMessage = error.localizedDescription
            showAlert = true
        }
    }
}

struct NewSubscriptionView_Previews: PreviewProvider {
    static var previews: some View {
        NewSubscriptionView(user: User.example, addedNewSubscription: .constant(false))
    }
}
