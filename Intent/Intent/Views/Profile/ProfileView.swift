//
//  ProfileView.swift
//  Intent
//
//  Created by Nyaradzo Bere on 9/3/23.
//

import Foundation
import SwiftUI
import SDWebImageSwiftUI
import Firebase

struct ProfileView: View {
    var user: User
    @State private var averageRatings: [String: Double] = [:]
    @State private var isRatingViewPresented = false

    var body: some View {
        NavigationView {
            ScrollView(showsIndicators: false) {
                VStack {
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

                    // Display average ratings or "No ratings yet" text
                    if averageRatings.isEmpty {
                        Text("No ratings yet")
                            .font(.headline)
                            .padding()
                    } else {
                        ForEach(averageRatings.sorted(by: { $0.key < $1.key }), id: \.key) { (category, rating) in
                            Text("\(category.capitalized) Rating: \(String(format: "%.1f", rating))")
                                .font(.headline)
                                .padding(.bottom)
                        }
                    }

                    // "We went on a date" button
                    NavigationLink(
                        destination: RatingView(ratedUser: user),
                        isActive: $isRatingViewPresented
                    ) {
                        EmptyView()
                    }
                    Button(action: {
                        self.isRatingViewPresented.toggle()
                    }) {
                        Text("We went on a date")
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                    .padding()
                }
            }
            .navigationBarHidden(true)
            .onAppear {
                // Calculate and load the average ratings
                calculateAverageRatings()
            }
            .onAppear {
                UIScrollView.appearance().showsVerticalScrollIndicator = false
            }
        }
    }

    private func calculateAverageRatings() {
        let db = Firestore.firestore()
        let ratingsCollection = db.collection("ratings")
        
        ratingsCollection.whereField("ratedUserID", isEqualTo: user.id ?? "")
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
                    totalRatings["comfortability"] = (totalRatings["comfortability"] ?? 0) + Double(comfortabilityRating)
                    totalRatings["presentation"] = (totalRatings["presentation"] ?? 0) + Double(presentationRating)
                    totalRatings["conversationQuality"] = (totalRatings["conversationQuality"] ?? 0) + Double(conversationQualityRating)

                    ratingCounts["promptness"] = (ratingCounts["promptness"] ?? 0) + 1
                    ratingCounts["respectfulness"] = (ratingCounts["respectfulness"] ?? 0) + 1
                    ratingCounts["comfortability"] = (ratingCounts["comfortability"] ?? 0) + 1
                    ratingCounts["presentation"] = (ratingCounts["presentation"] ?? 0) + 1
                    ratingCounts["conversationQuality"] = (ratingCounts["conversationQuality"] ?? 0) + 1
                }

                for (key, value) in totalRatings {
                    let average = value / Double(ratingCounts[key] ?? 1)
                    self.averageRatings[key] = average
                }
            }
    }
}

struct ProfileView_Previews: PreviewProvider {
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

        return ProfileView(user: user)
    }
}
