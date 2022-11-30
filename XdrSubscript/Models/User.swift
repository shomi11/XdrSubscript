//
//  User.swift
//  XdrSubscript
//
//  Created by Malovic, Milos on 18.11.22..
//

import Foundation
import FirebaseFirestoreSwift

struct User: Codable, Equatable, Hashable, Identifiable {
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(email)
    }
    
    @DocumentID var id: String?
    var userID: String
    var name: String
    var email: String
    
    enum CodingKeys: String, CodingKey {
        case userID
        case name
        case email
    }
    
    static var example: User {
        return User(id: "", userID: "", name: "Milos", email: "ma@gmail.com")
    }
}
