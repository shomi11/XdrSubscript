//
//  SubscriptionDetailsView.swift
//  XdrSubscript
//
//  Created by Malovic, Milos on 18.11.22..
//

import SwiftUI
import UserNotifications

struct SubscriptionDetailsView: View {
        
    @EnvironmentObject private var appState: AppState
    @Environment(\.managedObjectContext) var moc
    @Environment(\.dismiss) var dismiss
    @State private var showAlert = false
    @State private var showErrorAlert = false
    @State private var showSuccessDeletedView = false
    @State private var showLoader = false
    @State private var errorMessage: String = ""
    @State var subcription: Subscription
    @State private var notificationOn: Bool = false
    @State private var urlString: String = ""
    
    var selectedCurrency = UserDefaults.standard.value(forKey: "selectedCurrency") as? String ?? "USD"
    
    var formater: NumberFormatter {
        let formater = NumberFormatter()
        formater.currencyCode = selectedCurrency
        formater.currencySymbol = selectedCurrency
        formater.numberStyle = .decimal
        formater.formatWidth = 2
        return formater
    }
    
    var body: some View {
        ZStack {
            Form {
                Section {
                    TextField("Subscription Name", text: $subcription.name)
                } header: {
                    Text("Subscription Name")
                }
                Section {
                    TextField("0.00", value: $subcription.price, formatter: formater)
                    #if os(iOS)
                        .keyboardType(.decimalPad)
                    #endif
                } header: {
                    Text("Subscription Price \(selectedCurrency)")
                }
                if !subcription.isFault {
                    Section {
                        DatePicker("Start Date", selection: $subcription.startDate, displayedComponents: [.date])
                    } header: {
                        Text("Subscription dates")
                    }
                }
                
                notificationManageView
                imageUrlView
                
                Section {
                    Button {
                        subcription.movedToHistory = true
                        subcription.dateMovedToHistory = Date()
                        try? moc.save()
                        dismiss()
                    } label: {
                        Label("Move To History", systemImage: "calendar.badge.clock")
                    }
                    .buttonStyle(.plain)
                }
                
                Section {
                    Button {
                        showAlert = true
                    } label: {
                        Label("Delete", systemImage: "trash")
                            .foregroundColor(.red)
                            .fontWeight(.semibold)
                    }
                    .buttonStyle(.plain)
                }
            }
            if showSuccessDeletedView {
                SuccessView(title: "SubscriptionDeleted", message: "", showSelf: $showSuccessDeletedView)
            }
            if showLoader {
                SpinnerView()
            }
        }
        .onChange(of: showSuccessDeletedView, perform: { newValue in
            if newValue == false {
                dismiss()
            }
        })
        .toolbar(content: {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    updateSubcription()
                } label: {
                    Text("Update")
                        .fontWeight(.semibold)
                }
            }
        })
        .alert("Delete \(subcription.name) ?", isPresented: $showAlert, actions: {
            Button("OK") { deleteSubscription() }
            Button("Cancel", role: .cancel, action: {})
        })
        .alert(Text(errorMessage), isPresented: $showErrorAlert, actions: {
            Button("OK", action: {})
        })
        .onAppear(perform: {
            notificationOn = subcription.notificationOn
            urlString = subcription.imageUrl
        })
        .navigationTitle("\(subcription.name)")
    }
    
    private var notificationManageView: some View {
        Section {
            Toggle("Notification", isOn: $notificationOn)
        } header: {
            Text("Notification Manage")
        }
    }
    
    private var imageUrlView: some View {
        Section {
            TextField("one.google.com", text: $urlString)
        } header: {
            Text("Subcription Provider url")
        }
    }
    
    private func deleteSubscription() {
        let object = moc.object(with: subcription.objectID)
        moc.delete(object)
        
        appState.objectWillChange.send()
        if let index = appState.subscriptions.firstIndex(where: {$0.id == subcription.id}) {
            appState.subscriptions.remove(at: index)
        }
        DispatchQueue.main.async {
            do {
                try moc.save()
                dismiss()
            }
            catch {
                print("==== cant delete object")
            }
        }
    }
    
    private func updateSubcription() {
        do {
            appState.subscriptions.forEach { sub in
                if sub.id == subcription.id {
                    sub.name = subcription.name
                    sub.startDate = subcription.startDate
                    sub.price = subcription.price
                    sub.type = subcription.type
                    sub.notificationOn = notificationOn
                    sub.imageUrl = urlString
                    if !notificationOn {
                        let identidier = subcription.id.uuidString
                        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [identidier])
                    }
                    appState.objectWillChange.send()
                }
            }
            try moc.save()
            dismiss()
        }
        catch {
            print("error update sub \(error)")
        }
    }
}

struct SubscriptionDetailsView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            SubscriptionDetailsView(subcription: DataController.subs.first!)
                .environmentObject(DataController())
        }
    }
}
