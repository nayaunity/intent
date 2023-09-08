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
    @State private var averageRatings: [String: Double] = [:]
    @State private var overallAverage: Double = 0.0 // Declare the overallAverage variable
    
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
                        
                        HStack {
                            VStack {
                                Text("Overall Rating: \(String(format: "%.2f", overallAverage))")
                                    .font(.headline)
                                    .padding(.bottom)
                                StarRatingView(rating: overallAverage, starColor: Color(hex: "#21258a"))
                                    .padding(.bottom)
                            }
                        }
                        if averageRatings.isEmpty {
                            Text("No ratings yet")
                                .font(.headline)
                                .padding()
                        } else {
                            ForEach(averageRatings.sorted(by: {
                                ratingCategoryOrder[$0.key.lowercased()] ?? Int.max <
                                ratingCategoryOrder[$1.key.lowercased()] ?? Int.max
                            }), id: \.key) { (category, rating) in
                                VStack {
                                    Text("\(category.capitalized): \(String(format: "%.2f", rating))")
                                        .font(.headline)
                                        .padding(.bottom)
                                    StarRatingView(rating: rating, starColor: Color(hex: "#21258a"))
                                        .padding(.bottom)
                                }
                            }
                        }
                    }
                }
                .navigationBarHidden(true)
                .onAppear {
                    // Calculate and load the user's own ratings
                    loadUserProfile()
                    calculateAverageRatings()
                }
                .onAppear {
                    UIScrollView.appearance().showsVerticalScrollIndicator = false
                }
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

    // Function to load the user's own ratings and calculate overall average
    private func calculateAverageRatings() {
        let db = Firestore.firestore()
        let ratingsCollection = db.collection("ratings")

        ratingsCollection.whereField("ratedUserID", isEqualTo: userId ?? "")
            .getDocuments { (snapshot, error) in
                if let error = error {
                    print("Error fetching ratings: \(error)")
                    return
                }

                var totalRatings: [String: Double] = [:]
                var ratingCounts: [String: Int] = [:]

                for document in snapshot?.documents ?? [] {
                    let data = document.data()
                    let promptnessRating = data["promptnessRating"] as? Int ?? 0
                    let respectfulnessRating = data["respectfulnessRating"] as? Int ?? 0
                    let comfortabilityRating = data["comfortabilityRating"] as? Int ?? 0
                    let presentationRating = data["presentationRating"] as? Int ?? 0
                    let conversationQualityRating = data["conversationQualityRating"] as? Int ?? 0

                    totalRatings["promptness"] = (totalRatings["promptness"] ?? 0) + Double(promptnessRating)
                    totalRatings["respectfulness"] = (totalRatings["respectfulness"] ?? 0) + Double(respectfulnessRating)
                    totalRatings["comfortability/Safety"] = (totalRatings["comfortability"] ?? 0) + Double(comfortabilityRating)
                    totalRatings["Picture Match"] = (totalRatings["presentation"] ?? 0) + Double(presentationRating)
                    totalRatings["Conversation Quality"] = (totalRatings["conversationQuality"] ?? 0) + Double(conversationQualityRating)

                    ratingCounts["promptness"] = (ratingCounts["promptness"] ?? 0) + 1
                    ratingCounts["respectfulness"] = (ratingCounts["respectfulness"] ?? 0) + 1
                    ratingCounts["comfortability"] = (ratingCounts["comfortability"] ?? 0) + 1
                    ratingCounts["presentation"] = (ratingCounts["presentation"] ?? 0) + 1
                    ratingCounts["conversationQuality"] = (ratingCounts["conversationQuality"] ?? 0) + 1
                }

                var overallTotalRating = 0.0

                for (key, value) in totalRatings {
                    let average = value / Double(ratingCounts[key] ?? 1)
                    self.averageRatings[key] = average
                    print("\(key) Average Rating: \(average)")
                    
                    // Calculate the overall total rating based on category averages
                    overallTotalRating += average
                }
                
                // Calculate the overall average rating
                overallAverage = overallTotalRating / 5
                print("Overall Average Rating: \(overallAverage)")
            }
    }

}

struct PersonalProfileView_Previews: PreviewProvider {
    static var previews: some View {
        PersonalProfileView(userId: "fRo8nSNAUHSfdjDuXROCyVik8U83")
    }
}
