//
//  RatingView.swift
//  Intent
//
//  Created by Nyaradzo Bere on 9/7/23.
//

import Foundation
import SwiftUI
import Firebase

struct RatingView: View {
    @State private var promptnessRating = 0
    @State private var respectfulnessRating = 0
    @State private var comfortabilityRating = 0
    @State private var presentationRating = 0
    @State private var conversationQualityRating = 0
    @State private var isRatingSubmitted = false
    @State private var showSuccessMessage = false

    // Add properties for tracking the current user
    @State private var currentUser: User?
    @State private var isCurrentUserLoaded = false
    
    var ratedUser: User

    init(ratedUser: User) {
        self.ratedUser = ratedUser

        // Load the current user if available
        loadCurrentUser()
    }

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
                self.isRatingSubmitted = true
                self.showSuccessMessage = true
                Timer.scheduledTimer(withTimeInterval: 1.0, repeats: false) { _ in
                    self.showSuccessMessage = false
                }

                // Submit the rating to Firestore
                submitRatingToFirestore()
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

    private func loadCurrentUser() {
        if let user = Auth.auth().currentUser {
            // Load the current user's data if available
            // You can fetch user data from Firestore or wherever it's stored
            currentUser = User(id: user.uid, name: user.displayName ?? "", bio: "", email: user.email ?? "", sex: "", genderIdentity: "", profilePictureUrl: "", rating: nil)
        }
        isCurrentUserLoaded = true
    }

    private func submitRatingToFirestore() {
        guard let currentUserID = Auth.auth().currentUser?.uid else { return }

        let db = Firestore.firestore()
        let ratingsCollection = db.collection("ratings")

        // Create a document with the rating data
        let ratingData: [String: Any] = [
            "raterID": currentUserID ?? "",
            "ratedUserID": ratedUser.id ?? "",
            "timestamp": Timestamp(),
            "promptnessRating": promptnessRating,
            "respectfulnessRating": respectfulnessRating,
            "comfortabilityRating": comfortabilityRating,
            "presentationRating": presentationRating,
            "conversationQualityRating": conversationQualityRating
        ]

        // Add the document to the "ratings" collection
        ratingsCollection.addDocument(data: ratingData) { error in
            if let error = error {
                print("Error adding rating: \(error)")
            } else {
                print("Rating added successfully!")
            }
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
