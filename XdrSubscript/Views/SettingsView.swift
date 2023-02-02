//
//  SettingsView.swift
//  XdrSubscript
//
//  Created by Malovic, Milos on 18.11.22..
//

import SwiftUI


struct SettingsView: View {
    
    var formater: NumberFormatter {
        let formater = NumberFormatter()
        formater.currencyCode = selectedCurrency
        formater.currencySymbol = selectedCurrency
        formater.numberStyle = .decimal
        formater.formatWidth = 2
        return formater
    }
    
    @EnvironmentObject private var appState: AppState
    @State private var currencyModel = CurrencyModel()
    @State private var selectedCurrency = UserDefaults.standard.value(forKey: "selectedCurrency") as? String ?? "USD"
    @State private var notificationEnabled = UserDefaults.standard.bool(forKey: "notificationEnabled")
      
    private enum FocusedField {
        case ammount
        case userName
    }
    
    @FocusState private var focusedField: FocusedField?
    
    var body: some View {
        NavigationStack {
            Form {
                currencySettings
                maximumSpendingPerMonthSettings
                userNameView
            }
            .navigationTitle("Settings")
        }
    }
    
    private var maximumSpendingPerMonthSettings: some View {
        Section {
            TextField("Ammount", value: $appState.maxSpending, formatter: formater)
                .focused($focusedField, equals: .ammount)
            #if os(iOS)
                .keyboardType(.decimalPad)
            #endif
                .toolbar {
                    ToolbarItem(placement: .keyboard) {
                        HStack {
                            Spacer()
                            Button("Confirm") {
                                if focusedField == .ammount {
                                    if appState.maxSpending != 0.0 {
                                        UserDefaults.standard.set(appState.maxSpending, forKey: "max_spending")
                                        focusedField = nil
                                    } else {
                                        appState.maxSpending = 0.0
                                        focusedField = nil
                                    }
                                } else if focusedField == .userName {
                                    UserDefaults.standard.set(appState.userName, forKey: "userName")
                                    focusedField = nil
                                }
                            }
                        }
                    }
                }
        } header: {
            Text("Set Maximum Monthly Spending")
        } footer: {
            Text("If you like to track how much you are above or bellow spending limit .")
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
    
    private var userNameView: some View {
        Section {
            TextField("Username", text: $appState.userName)
                .focused($focusedField, equals: .userName)
        } header: {
            Text("Username")
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
