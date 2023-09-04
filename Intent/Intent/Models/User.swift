//
//  User.swift
//  Intent
//
//  Created by Nyaradzo Bere on 9/3/23.
//

import Foundation
import Firebase
import FirebaseFirestoreSwift

struct User: Identifiable, Codable {
    @DocumentID var id: String?
    var name: String
    var bio: String
    var email: String
    var sex: String
    var genderIdentity: String
    var profilePictureUrl: String
    var rating: Double?

    enum CodingKeys: String, CodingKey {
        case id
        case name
        case bio
        case email
        case sex
        case genderIdentity = "genderIdentity"
        case profilePictureUrl = "profilePictureUrl"
        case rating
    }

    init?(fromSnapshot snapshot: QueryDocumentSnapshot) {
        guard let data = try? snapshot.data(as: User.self) else {
            return nil
        }
        self = data
    }
}
