//
//  User.swift
//  XdrSubscript
//
//  Created by Malovic, Milos on 18.11.22..
//

import Foundation
import FirebaseFirestoreSwift
import RevenueCat

class User: Codable, Equatable, Hashable, Identifiable {
    
    
    init(id: String?, userID: String, name: String, email: String, isSubscriptionStatusActive: Bool = false) {
        self.id = id
        self.userID = userID
        self.name = name
        self.email = email
        self.isSubscriptionStatusActive = isSubscriptionStatusActive
        
        setSubscriptionStatus()
    }
      
    
    static func == (lhs: User, rhs: User) -> Bool {
        lhs.userID == rhs.userID
    }
   
  
    
     func setSubscriptionStatus() {
        Purchases.shared.getCustomerInfo { info, error in
            guard error == nil else { return }
            self.isSubscriptionStatusActive = info?.entitlements["Premium"]?.isActive == true
        }
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(email)
    }
    
    @DocumentID var id: String?
    var userID: String
    var name: String
    var email: String
    var isSubscriptionStatusActive: Bool = false
    
    enum CodingKeys: String, CodingKey {
        case userID
        case name
        case email
    }
    
    static var example: User {
        return User(id: "123", userID: "", name: "Milos", email: "ma@gmail.com")
    }
}
