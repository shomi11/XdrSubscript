//
//  PayWallView.swift
//  XdrSubscript
//
//  Created by Malovic, Milos on 1.12.22..
//

import SwiftUI
import RevenueCat

struct PayWallView: View {
    
    @Environment(\.dismiss) private var dismiss
    @State private var monthlyPrice: String = ""
    @State private var showAlert: Bool = false
    @State private var errorMessage: String = ""
    @State private var monthlyPk: Package?
    @State private var isPurchaisng: Bool = false
    @State private var showSuccessView: Bool = false
    @State var user: User
    
    
    var body: some View {
        NavigationStack {
            ZStack {
                Image("shape")
                    .resizable()
                    .scaledToFit()
                    .padding(.horizontal)
                VStack(alignment: .center, spacing: 16) {
                    Text("Manage your subcriptions easily")
                        .multilineTextAlignment(.center)
                        .padding(.bottom)
                        .font(.title3)
                        .fontWeight(.heavy)
                    HStack(spacing: 16) {
                        HStack(alignment: .center, spacing: 16) {
                            Image(systemName: "note.text.badge.plus")
                                .resizable()
                                .scaledToFit()
                                .frame(maxWidth: 30)
                                .foregroundColor(.indigo)
                                .font(.title3)
                                .bold()
                        }
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Add unlimited number of subscriptions")
                                .fontWeight(.medium)
                                .fontDesign(.rounded)
                                .font(.callout)
                            
                        }
                        Spacer()
                    }
                    HStack(spacing: 16) {
                        HStack(alignment: .center, spacing: 16) {
                            Image(systemName: "bell")
                                .resizable()
                                .scaledToFit()
                                .frame(maxWidth: 30)
                                .foregroundColor(.indigo)
                                .font(.title3)
                                .bold()
                        }
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Get notifications about your subcriptions")
                                .fontWeight(.medium)
                                .fontDesign(.rounded)
                                .font(.callout)
                        }
                        Spacer()
                    }
                    HStack(spacing: 16) {
                        HStack(alignment: .center, spacing: 16) {
                            Image(systemName: "bell.badge")
                                .resizable()
                                .scaledToFit()
                                .frame(maxWidth: 30)
                                .foregroundColor(.indigo)
                                .font(.title3)
                                .bold()
                        }
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Set custom notifications")
                                .fontWeight(.medium)
                                .fontDesign(.rounded)
                                .font(.callout)
                            
                        }
                        Spacer()
                    }
                    VStack(alignment: .center, spacing: 8) {
                        Button {
                            buyMonthlyPackage()
                        } label: {
                            VStack(alignment: .center, spacing: 6) {
                                Text(monthlyPrice)
                                    .fontWeight(.medium)
                                    .fontDesign(.rounded)
                                Text("Go Premium")
                                    .fontWeight(.heavy)
                                    .fontDesign(.rounded)
                            }
                            .padding()
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(.indigo)
                    }
                    .padding(.top)
                }
                .padding(.vertical, 32)
                .padding(.leading, 32)
                .padding(.trailing, 16)
                .background(.thinMaterial)
                .padding(.horizontal)
                if isPurchaisng {
                    SpinnerView()
                }
                if showSuccessView {
                    SuccessView(
                        title: "Purchase Completed",
                        message: "Enjoy full access.",
                        showSelf: $showSuccessView)
                }
            }
            .onChange(of: showSuccessView, perform: { newValue in
                if newValue == false {
                    dismiss()
                }
            })
            .alert("Sorry something went wrong", isPresented: $showAlert, actions: {
                Button.init("OK") { dismiss() }
            }, message: {
                Text(errorMessage)
            })
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Premium".uppercased())
                        .fontWeight(.bold)
                        .foregroundColor(.indigo)
                }
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .foregroundColor(.primary)
                    }
                }
            }
            .onAppear {
                getOffers()
            }
        }
        .blur(radius: isPurchaisng ? 5 : 0)
    }
    
    private func buyMonthlyPackage() {
        isPurchaisng = true
        if let pk = monthlyPk {
            Purchases.shared.purchase(package: pk) { transaction, customerInfo, error, userCancelled in
                isPurchaisng = false
                guard error == nil else {
                    errorMessage = error!.localizedDescription
                    showAlert = true
                    return
                }
                if customerInfo?.entitlements.all["Premium"]?.isActive == true {
                    user.isSubscriptionStatusActive = true
                    showSuccessView = true
                }
            }
        }
    }
    
    private func getOffers() {
        Purchases.shared.getOfferings { offerings, error in
            if let error = error {
                errorMessage = error.localizedDescription
                showAlert = true
            } else {
                if let monthlyOffer = offerings?.current?.monthly {
                    monthlyPk = monthlyOffer
                    let price = monthlyOffer.localizedPriceString
                    monthlyPrice = price + " /monthly"
                }
            }
        }
    }
}

struct PayWallView_Previews: PreviewProvider {
    static var previews: some View {
        PayWallView(user: User.example)
    }
}
