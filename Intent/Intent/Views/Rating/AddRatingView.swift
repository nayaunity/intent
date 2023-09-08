//
//  RatingView.swift
//  Intent
//
//  Created by Nyaradzo Bere on 9/7/23.
//

import SwiftUI
import Firebase

struct AddRatingView: View {
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
            
            // Ratings for conversation quality with info button
            RatingCategoryView(
                category: "Conversation Quality",
                rating: $conversationQualityRating,
                infoButtonAction: {
                    // Show an info popup for "Conversation Quality" category
                    self.showInfoPopup(title: "Conversation Quality Info", message: "Was the conversation engaging? Did they listen as much as they spoke?")
                }
            )
            
            // Ratings for presentation with info button
            RatingCategoryView(
                category: "Picture Match",
                rating: $presentationRating,
                infoButtonAction: {
                    // Show an info popup for "Presentation" category
                    self.showInfoPopup(title: "Picture Match Info", message: "Did they look like their pictures?")
                }
            )
            
            // Ratings for promptness with info button
            RatingCategoryView(
                category: "On Time",
                rating: $promptnessRating,
                infoButtonAction: {
                    // Show an info popup for "Promptness" category
                    // You can implement this as a popover or alert
                    // Example:
                    // self.showInfoPopup(category: "Promptness")
                    self.showInfoPopup(title: "Promptness Info", message: "Rate how prompt your date was.\n\n5 = Perfectly on time or early\n4 = Slightly late (0-10 minutes)\n3 = Moderately late (11-20 minutes)\n2 = Quite late (21-30 minutes)\n1 = Over 30 minutes late")
                }
            )

            // Ratings for respectfulness with info button
            RatingCategoryView(
                category: "Respectful",
                rating: $respectfulnessRating,
                infoButtonAction: {
                    // Show an info popup for "Respectfulness" category
                    self.showInfoPopup(title: "Respectfulness Info", message: "Did they treat you with respect and kindness?")
                }
            )

            // Ratings for comfortability/safety with info button
            RatingCategoryView(
                category: "Comfortability/Safety",
                rating: $comfortabilityRating,
                infoButtonAction: {
                    // Show an info popup for "Comfortability/Safety" category
                    self.showInfoPopup(title: "Comfortability/Safety Info", message: "Did you feel safe during the date?")
                }
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
                    .background(Color(hex: "C0C0C0"))
                    .foregroundColor(.black)
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
    
    private func showInfoPopup(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "I understand", style: .default, handler: nil))
        UIApplication.shared.windows.first?.rootViewController?.present(alert, animated: true, completion: nil)
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

struct AddRatingView_Previews: PreviewProvider {
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

        return AddRatingView(ratedUser: user)
    }
}
