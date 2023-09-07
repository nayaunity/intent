//
//  Rating.swift
//  Intent
//
//  Created by Nyaradzo Bere on 9/7/23.
//

import Foundation
import Firebase
import FirebaseFirestoreSwift

struct Rating: Identifiable {
    var id: String?
    var raterID: String
    var ratedID: String
    var timestamp: Date
    var promptnessRating: Int
    var respectfulnessRating: Int
    var comfortabilityRating: Int
    var presentationRating: Int
    var conversationQualityRating: Int
}
