//
//  UserRatingsView.swift
//  Intent
//
//  Created by Nyaradzo Bere on 9/7/23.
//

import Foundation
import SwiftUI

//struct UserRatingsView: View {
//    var promptnessRating: Int
//    var respectfulnessRating: Int
//    var comfortabilityRating: Int
//    var presentationRating: Int
//    var conversationQualityRating: Int
//
//    var body: some View {
//        VStack(alignment: .leading) {
//            Text("Ratings")
//                .font(.headline)
//                .padding(.bottom, 4)
//
//            RatingCategoryView(category: "Promptness", rating: $promptnessRating)
//            RatingCategoryView(category: "Respectfulness", rating: $respectfulnessRating)
//            RatingCategoryView(category: "Comfortability/Safety", rating: $comfortabilityRating)
//            RatingCategoryView(category: "Presentation", rating: $presentationRating)
//            RatingCategoryView(category: "Conversation Quality", rating: $conversationQualityRating)
//
//            // Display the overall average rating
//            Text("Overall Rating: \(calculateOverallRating())")
//                .font(.subheadline)
//                .foregroundColor(.gray)
//                .padding(.top, 8)
//        }
//        .padding()
//        .background(Color.white)
//        .cornerRadius(10)
//        .shadow(radius: 1)
//    }
//
//    func calculateOverallRating() -> Double {
//        // Calculate the overall average rating based on individual ratings
//        let totalRatings = Double(promptnessRating + respectfulnessRating + comfortabilityRating + presentationRating + conversationQualityRating)
//        return totalRatings / 5.0
//    }
//}
