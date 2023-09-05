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

    // Default initializer to ensure all properties are initialized
    init(id: String? = nil, name: String = "", bio: String = "", email: String = "", sex: String = "", genderIdentity: String = "", profilePictureUrl: String = "", rating: Double? = nil) {
        self.id = id
        self.name = name
        self.bio = bio
        self.email = email
        self.sex = sex
        self.genderIdentity = genderIdentity
        self.profilePictureUrl = profilePictureUrl
        self.rating = rating
    }
}
