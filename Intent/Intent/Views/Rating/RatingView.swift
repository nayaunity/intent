//
//  RatingView.swift
//  Intent
//
//  Created by Nyaradzo Bere on 9/7/23.
//

import Foundation
import SwiftUI

struct RatingView: View {
    @State private var promptnessRating = 0
    @State private var respectfulnessRating = 0
    @State private var comfortabilityRating = 0
    @State private var presentationRating = 0
    @State private var conversationQualityRating = 0
    @State private var isRatingSubmitted = false
    @State private var showSuccessMessage = false // Moved here

    var ratedUser: User

    var body: some View {
        VStack {
            Text("Rate your date with \(ratedUser.name)")
                .font(.title)
                .padding()

            // Ratings for promptness
            RatingCategoryView(
                category: "Promptness",
                rating: $promptnessRating
            )

            // Ratings for respectfulness
            RatingCategoryView(
                category: "Respectfulness",
                rating: $respectfulnessRating
            )

            // Ratings for comfortability/safety
            RatingCategoryView(
                category: "Comfortability/Safety",
                rating: $comfortabilityRating
            )

            // Ratings for presentation
            RatingCategoryView(
                category: "Presentation",
                rating: $presentationRating
            )

            // Ratings for conversation quality
            RatingCategoryView(
                category: "Conversation Quality",
                rating: $conversationQualityRating
            )

            // Submit Rating Button
            Button(action: {
                // Handle submitting the ratings to the database or perform other actions
                self.isRatingSubmitted = true
                // Show the success message
                self.showSuccessMessage = true
                // Automatically hide the success message after 1 second
                Timer.scheduledTimer(withTimeInterval: 1.0, repeats: false) { _ in
                    self.showSuccessMessage = false
                }
            }) {
                Text("Submit Rating")
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
            .disabled(isRatingSubmitted)
            .padding()
        }
        .navigationBarHidden(true)
        .alert(isPresented: $showSuccessMessage) {
            Alert(
                title: Text("Rating submitted successfully!"),
                dismissButton: .default(Text("OK"))
            )
        }
    }
}

struct RatingCategoryView: View {
    var category: String
    @Binding var rating: Int

    var body: some View {
        VStack {
            Text(category)
                .font(.headline)
                .padding()

            HStack {
                ForEach(1 ..< 6) { star in
                    Image(systemName: star <= rating ? "star.fill" : "star")
                        .resizable()
                        .frame(width: 40, height: 40)
                        .foregroundColor(Color.yellow)
                        .onTapGesture {
                            self.rating = star
                        }
                }
            }
        }
    }
}

struct RatingView_Previews: PreviewProvider {
    static var previews: some View {
        let user = User(
            id: "1",
            name: "John Doe",
            bio: "Friendly and outgoing",
            email: "john@example.com",
            sex: "Male",
            genderIdentity: "Man",
            profilePictureUrl: "https://example.com/profile.jpg",
            rating: 4.5
        )

        return RatingView(ratedUser: user)
    }
}
