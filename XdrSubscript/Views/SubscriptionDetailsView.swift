//
//  SubscriptionDetailsView.swift
//  XdrSubscript
//
//  Created by Malovic, Milos on 18.11.22..
//

import SwiftUI
import FirebaseFirestoreSwift
import Firebase

struct SubscriptionDetailsView: View {
  
    
    @Environment(\.dismiss) var dismiss
    @State var subcription: Subscription
    @State var user: User
    @State private var showAlert = false
    @State private var showErrorAlert = false
    @State private var showSuccessDeletedView = false
    @State private var showLoader = false
    @State private var errorMessage: String = ""
    
    private let db = Firestore.firestore()
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
                        .keyboardType(.numberPad)
                } header: {
                    Text("Subscription Price \(selectedCurrency)")
                }
                Section {
                    DatePicker("Start Date", selection: $subcription.startDate, displayedComponents: [.date])
                } header: {
                    Text("Subscription dates")
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
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    updateSubcription()
                } label: {
                    Text("Update")
                        .fontWeight(.semibold)
                }
            }
        })
        .alert("Delete \(subcription.name) ?", isPresented: $showAlert, actions: {
            Button("OK") {
                deleteSubscription()
            }
        })
        .alert(Text(errorMessage), isPresented: $showErrorAlert, actions: {
            Button("OK", action: {})
        })
        .navigationTitle("\(subcription.name)")
    }
    
    private func deleteSubscription() {
        showLoader = true
        db.collection("Users").document(user.userID).collection("subscriptions").document(subcription.id ?? "").delete { error in
            showLoader = false
            if let error = error {
                errorMessage = error.localizedDescription
                showErrorAlert = true
            } else {
                showSuccessDeletedView = true
            }
        }
    }
    
    private func updateSubcription() {
        
        guard subcription.name.isEmpty else {
            errorMessage = "Name can't be empty"
            showAlert = true
            return
        }
        
        showLoader = true
        do {
            try db.collection("Users").document(user.userID).collection("subscriptions").document(subcription.id ?? "").setData(from: subcription, merge: true) { error in
                showLoader = false
                if let error = error {
                    errorMessage = error.localizedDescription
                    showAlert = true
                }
            }
        }
        catch {
            showLoader = false
            errorMessage = error.localizedDescription
            showAlert = true
        }
    }
}

struct SubscriptionDetailsView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            SubscriptionDetailsView(subcription: Subscription.subs.first!, user: User.example)
        }
    }
}
