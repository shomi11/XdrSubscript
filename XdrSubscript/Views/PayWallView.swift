//
//  PayWallView.swift
//  XdrSubscript
//
//  Created by Malovic, Milos on 1.12.22..
//

import SwiftUI

struct PayWallView: View {
    
    @Environment(\.dismiss) private var dismiss
    
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
                            
                        } label: {
                            VStack(alignment: .center, spacing: 6) {
                                Text("$1.99 / month")
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
            }
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
        }
        
    }
}

struct PayWallView_Previews: PreviewProvider {
    static var previews: some View {
        PayWallView()
    }
}
