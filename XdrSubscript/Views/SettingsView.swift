//
//  SettingsView.swift
//  XdrSubscript
//
//  Created by Malovic, Milos on 18.11.22..
//

import SwiftUI
import FirebaseAuth

struct SettingsView: View {
    
    @Environment(\.dismiss) var dismiss
    @State private var currencyModel = CurrencyModel()
    @State private var selectedCurrency = UserDefaults.standard.value(forKey: "selectedCurrency") as? String ?? "USD"
    @State private var notificationEnabled = UserDefaults.standard.bool(forKey: "notificationEnabled")
    var body: some View {
        NavigationStack {
            Form {
                authSection
                currencySettings
            }
            .navigationTitle("Settings")
        }
        .onAppear {
            print(selectedCurrency)
        }
    }
    
    private var currencySettings: some View {
        Section {
            Picker("Choose your currency code", selection: $selectedCurrency) {
                ForEach(currencyModel.currencyCodes.map({$0.identifier}), id: \.self) { code in
                    Text(code)
                }
            }
            .onChange(of: selectedCurrency) { newValue in
                UserDefaults.standard.set(newValue, forKey: "selectedCurrency")
            }
        }
    }
    
    private var authSection: some View {
        Section {
            Button {
                do {
                    try Auth.auth().signOut()
                    dismiss()
                } catch {
                    print(error.localizedDescription)
                }
            } label: {
                Text("Sign Out")
                    .foregroundColor(.blue)
            }
            .buttonStyle(.plain)
           
            Button {
                
            } label: {
                Text("Delete Account")
                    .foregroundColor(.red)
            }
            .buttonStyle(.plain)
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
