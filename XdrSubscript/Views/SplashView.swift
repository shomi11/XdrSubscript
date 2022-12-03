//
//  SplashView.swift
//  XdrSubscript
//
//  Created by Malovic, Milos on 18.11.22..
//

import SwiftUI
import FirebaseAuth
import FirebaseFirestoreSwift
import Firebase
import RevenueCat

struct SplashView: View {
    
    @State private var showMain: Bool = false
    @State private var showAuthView: Bool = false
    @State var user: User? = nil
    private var db = Firestore.firestore()
    
    var body: some View {
        ZStack {
            VStack(alignment: .center, spacing: 16) {
                Image("logo")
                    .resizable()
                    .scaledToFit()
                Text("Get Better With Your Finance $")
                    .fontWeight(.heavy)
                    .font(.title3)
            }
            .padding(.horizontal)
        }
        .ignoresSafeArea(.all)
        .onAppear {
            rootNextView()
        }
        .onChange(of: user, perform: { newValue in
            if newValue != nil {
                fetchUser(user: newValue!)
            }
        })
        .fullScreenCover(isPresented: $showMain) {
            if let user = user {
                MainTabView(user: user)
            }
        }
        .fullScreenCover(isPresented: $showAuthView) {
            AuthView()
        }
    }
    
    func fetchUser(user: User) {
        db.collection("Users").getDocuments { snap, error in
            if let documents = snap?.documents, documents.isEmpty == false {
                documents.forEach({ doc in
                    if doc.documentID == user.userID {
                        showMain = true
                    } else {
                        do {
                            try db.collection("Users").document(user.userID).setData(from: user) { error in
                                if let error = error {
                                    print("error adding user \(error.localizedDescription)")
                                } else {
                                    showMain = true
                                }
                            }
                        } catch {
                            print("failed \(error.localizedDescription)")
                        }
                    }
                })
            } else {
                do {
                    try db.collection("Users").document(user.userID).setData(from: user) { error in
                        if let error = error {
                            print("error adding user \(error.localizedDescription)")
                        } else {
                            showMain = true
                        }
                    }
                } catch {
                    print("failed \(error.localizedDescription)")
                }
            }
        }
    }
    
    private func rootNextView()  {
        Auth.auth().addStateDidChangeListener { auth, user in
            if let user = user {
                self.user = User(
                    id: user.uid,
                    userID: user.uid,
                    name: user.displayName ?? "",
                    email: user.email ?? ""
                )
            } else {
                showAuthView = true
            }
        }
    }
}

struct SplashView_Previews: PreviewProvider {
    static var previews: some View {
        SplashView()
    }
}
