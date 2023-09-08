//
//  PersonalProfileView.swift
//  Intent
//
//  Created by Nyaradzo Bere on 9/6/23.
//

import SwiftUI
import Firebase
import SDWebImageSwiftUI

struct PersonalProfileView: View {
    @State private var user: User?
    let userId: String

    init(userId: String) {
        self.userId = userId
    }

    // Store the user's own ratings
    @State private var ownRatings: [String: Double] = [:]

    // Define the rating category order within the PersonalProfileView
    let ratingCategoryOrder: [String: Int] = [
        "conversation quality": 1,
        "picture match": 2,
        "promptness": 3,
        "respectfulness": 4,
        "comfortability/safety": 5
    ]

    var body: some View {
        NavigationView {
            ScrollView(showsIndicators: false) {
                VStack {
                    if let user = user {
                        WebImage(url: URL(string: user.profilePictureUrl))
                            .resizable()
                            .scaledToFit()
                            .clipShape(Circle())
                            .frame(width: 300, height: 400)
                            .padding()

                        Text(user.name)
                            .font(.largeTitle)
                            .padding()

                        Text(user.bio)
                            .font(.subheadline)
                            .foregroundColor(.gray)
                            .padding()

                        // Print statement to check if userId is correct
                        let _ = print("User ID: \(userId)")

                        // Display the user's own ratings
                        if !ownRatings.isEmpty {
                            Text("Your Ratings:")
                                .font(.headline)
                                .padding(.top)

                            // Print statement to check if ownRatings contains data
//                            Text(ownRatings)

                            ForEach(ownRatings.sorted(by: {
                                ratingCategoryOrder[$0.key.lowercased()] ?? Int.max <
                                ratingCategoryOrder[$1.key.lowercased()] ?? Int.max
                            }), id: \.key) { (category, rating) in
                                VStack {
                                    Text("\(category.capitalized): \(String(format: "%.2f", rating))")
                                        .font(.headline)
                                        .padding(.bottom)

                                    StarRatingView(rating: rating)
                                }
                            }
                        }
                    } else {
                        Text("Loading profile...")
                    }
                }
            }
            .navigationBarHidden(true)
            .onAppear {
                // Calculate and load the user's own ratings
                loadUserProfile()
                loadOwnRatings()
            }
            .onAppear {
                UIScrollView.appearance().showsVerticalScrollIndicator = false
            }
        }
    }

    func loadUserProfile() {
        let db = Firestore.firestore()
        let docRef = db.collection("users").document(userId)

        docRef.getDocument { (document, error) in
            if let document = document, document.exists, let data = document.data() {
                // Extract data from the document and initialize a User object
                let id = document.documentID
                let name = data["name"] as? String ?? ""
                let bio = data["bio"] as? String ?? ""
                let email = data["email"] as? String ?? ""
                let sex = data["sex"] as? String ?? ""
                let genderIdentity = data["genderIdentity"] as? String ?? ""
                let profilePictureUrl = data["profilePictureUrl"] as? String ?? ""
                let rating = data["rating"] as? Double

                // Initialize the user state
                self.user = User(id: id, name: name, bio: bio, email: email, sex: sex, genderIdentity: genderIdentity, profilePictureUrl: profilePictureUrl, rating: rating)
            } else {
                print("Document does not exist or there was an error: \(error?.localizedDescription ?? "Unknown error")")
            }
        }
    }

    // Function to load the user's own ratings
    func loadOwnRatings() {
        let db = Firestore.firestore()
        let ratingsCollection = db.collection("ratings")

        ratingsCollection.whereField("raterID", isEqualTo: userId).getDocuments { snapshot, error in
            if let error = error {
                print("Error fetching ratings: \(error.localizedDescription)")
                return
            }

            guard let snapshot = snapshot else {
                print("Snapshot is nil.")
                return
            }

            var ownRatings: [String: Double] = [:]

            for document in snapshot.documents {
                let data = document.data()

                if
                    let promptnessRating = data["promptnessRating"] as? Int,
                    let respectfulnessRating = data["respectfulnessRating"] as? Int,
                    let comfortabilityRating = data["comfortabilityRating"] as? Int,
                    let presentationRating = data["presentationRating"] as? Int,
                    let conversationQualityRating = data["conversationQualityRating"] as? Int {

                    // Calculate the average rating for each category
                    let ratings = [promptnessRating, respectfulnessRating, comfortabilityRating, presentationRating, conversationQualityRating]
                    
                    let sum = ratings.reduce(0) { result, ratings in
                        result + ratings
                    }
                    
                    let averageCategoryRating = Double(sum) / Double(ratings.count)

                    // Use the category name or a more descriptive field as the key
                    let categoryName = "Average Rating" // Change this to your desired category name
                    ownRatings[categoryName] = Double(averageCategoryRating)
                }
            }

            self.ownRatings = ownRatings
            print("Loaded Own Ratings: \(ownRatings)")
        }
    }


}

struct PersonalProfileView_Previews: PreviewProvider {
    static var previews: some View {
        PersonalProfileView(userId: "fRo8nSNAUHSfdjDuXROCyVik8U83")
    }
}
