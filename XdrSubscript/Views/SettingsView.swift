//
//  SettingsView.swift
//  XdrSubscript
//
//  Created by Malovic, Milos on 18.11.22..
//

import SwiftUI


struct SettingsView: View {
    
    @Environment(\.dismiss) var dismiss
    @State private var currencyModel = CurrencyModel()
    @State private var selectedCurrency = UserDefaults.standard.value(forKey: "selectedCurrency") as? String ?? "USD"
    @State private var notificationEnabled = UserDefaults.standard.bool(forKey: "notificationEnabled")
    
    var body: some View {
        NavigationStack {
            Form {
                currencySettings
            }
            .navigationTitle("Settings")
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
        } header: {
            Text("Currency")
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
