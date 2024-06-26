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

struct StarRatingView: View {
    let rating: Double
    let maxRating: Double = 5.0 // Maximum rating value (e.g., 5 stars)
    let starCount: Int = 5 // Number of stars in the rating
    let starColor: Color // Parameter to accept a custom star color

    init(rating: Double, starColor: Color) {
        self.rating = rating
        self.starColor = starColor
    }

    var body: some View {
        HStack {
            ForEach(1...starCount, id: \.self) { index in
                let doubleIndex = Double(index)
                let fullStar = min(max(0, rating - (doubleIndex - 1.0)), 1)
                let halfStar = min(max(0, rating - (doubleIndex - 0.5)), 0.5)

                Image(systemName: fullStar >= 0.9 ? "star.fill" : (fullStar >= 0.5 || halfStar >= 0.5) ? "star.leadinghalf.fill" : halfStar > 0.0 ? "star.half.fill" : "star")
                    .foregroundColor(fullStar > 0.0 ? starColor : .gray)
                    .font(.system(size: 20))
            }
        }
    }
}




struct ProfileView: View {
    var user: User
    @State private var averageRatings: [String: Double] = [:]
    @State private var isRatingViewPresented = false
    @State private var overallAverage: Double = 0.0 // Declare the overallAverage variable
    
    let ratingCategoryOrder: [String: Int] = [
        "conversationquality": 1, // Change the order for "Conversation Quality"
        "presentation": 2,        // Change the order for "Picture Match"
        "promptness": 3,
        "respectfulness": 4,
        "comfortability/safety": 5
    ]

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
                    
                    HStack {
                        VStack {
                            if overallAverage > 0 {
                                Text("Overall Rating: \(String(format: "%.2f", overallAverage))")
                                    .font(.headline)
                                    .padding(.bottom)
                                StarRatingView(rating: overallAverage, starColor: Color(hex: "#21258a"))
                                    .padding(.bottom)
                            }
                        }
                    }

                    // Display average ratings or "No ratings yet" text
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
                                Text("\(mapCategoryName(category).capitalized): \(String(format: "%.2f", rating))")
                                    .font(.headline)
                                    .padding(.bottom)
                                StarRatingView(rating: rating, starColor: Color(hex: "#21258a"))
                                    .padding(.bottom)
                            }
                        }
                    }

                    // "We went on a date" button
                    NavigationLink(
                        destination: AddRatingView(ratedUser: user),
                        isActive: $isRatingViewPresented
                    ) {
                        EmptyView()
                    }
                    Button(action: {
                        self.isRatingViewPresented.toggle()
                    }) {
                        Text("We went on a date")
                            .padding()
                            .background(Color(hex: "C0C0C0"))
                            .foregroundColor(.black)
                            .cornerRadius(8)
                    }
                    .padding()
                }
            }
            .navigationBarHidden(true)
            .onAppear {
                calculateAverageRatings()
            }
            .onAppear {
                UIScrollView.appearance().showsVerticalScrollIndicator = false
            }
        }
    }
    
    private func mapCategoryName(_ categoryName: String) -> String {
        switch categoryName.lowercased() {
        case "promptness":
            return "On Time"
        case "respectfulness":
            return "Respectful"
        case "conversationquality":
            return "Conversation Quality"
        case "presentation":
            return "Picture Match"
        case "comfortability/safety":
            return "Comfortability/Safety"
        default:
            return categoryName
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
