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
    @ObservedObject var userData: UserData
    let userId: String
    
    @State private var user: User?
    @State private var averageRatings: [String: Double] = [:]
    @State private var overallAverage: Double = 0.0
    @State private var isEditingProfile = false
    @State private var shouldRefresh = false

    init(userData: UserData, userId: String) {
        self.userData = userData
        self.userId = userId
    }

    @State private var ownRatings: [String: Double] = [:]

    let ratingCategoryOrder: [String: Int] = [
        "conversationquality": 1,
        "presentation": 2,
        "promptness": 3,
        "respectfulness": 4,
        "comfortability/safety": 5
    ]
    
    private var userBinding: Binding<User> {
        Binding<User>(
            get: {
                // Provide a default User if user is nil
                return user ?? User(id: "", name: "", bio: "", email: "", sex: "", genderIdentity: "", profilePictureUrl: "", rating: 0.0)
            },
            set: {
                // Update the user when the binding is set
                user = $0
            }
        )
    }

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
                                    Text("\(mapCategoryName(category).capitalized): \(String(format: "%.2f", rating))")
                                        .font(.headline)
                                        .padding(.bottom)
                                    StarRatingView(rating: rating, starColor: Color(hex: "#21258a"))
                                        .padding(.bottom)
                                }
                            }
                        }

                        HStack {
                            Button(action: {
                                isEditingProfile = true
                            }) {
                                Text("Edit Profile")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                    .padding()
                                    .background(Color.blue)
                                    .cornerRadius(10)
                            }
                            .sheet(isPresented: $isEditingProfile) {
                                EditProfileView(isPresented: $isEditingProfile, user: userBinding, userData: userData)
                            }
                        }
                    }
                }
                .navigationBarHidden(true)
                .onAppear {
                    loadUserProfile()
                    calculateAverageRatings()
                }
                .onAppear {
                    UIScrollView.appearance().showsVerticalScrollIndicator = false
                }
                .onAppear {
                    // Check the shouldRefresh flag and reload user profile if needed
                    if shouldRefresh {
                        loadUserProfile()
                        calculateAverageRatings()
                    }
                }
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
        case "comfortability":
            return "Comfortability/Safety"
        default:
            return categoryName
        }
    }

    func loadUserProfile() {
        let db = Firestore.firestore()
        let docRef = db.collection("users").document(userId)

        docRef.getDocument { (document, error) in
            if let document = document, document.exists, let data = document.data() {
                let id = document.documentID
                let name = data["name"] as? String ?? ""
                let bio = data["bio"] as? String ?? ""
                let email = data["email"] as? String ?? ""
                let sex = data["sex"] as? String ?? ""
                let genderIdentity = data["genderIdentity"] as? String ?? ""
                let profilePictureUrl = data["profilePictureUrl"] as? String ?? ""
                let rating = data["rating"] as? Double

                self.user = User(id: id, name: name, bio: bio, email: email, sex: sex, genderIdentity: genderIdentity, profilePictureUrl: profilePictureUrl, rating: rating)
            } else {
                print("Document does not exist or there was an error: \(error?.localizedDescription ?? "Unknown error")")
            }
        }
    }

    private func calculateAverageRatings() {
        let db = Firestore.firestore()
        let ratingsCollection = db.collection("ratings")

        ratingsCollection.whereField("ratedUserID", isEqualTo: userId)
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

                    overallTotalRating += average
                }

                overallAverage = overallTotalRating / 5
                print("Overall Average Rating: \(overallAverage)")
            }
    }
}

//struct PersonalProfileView_Previews: PreviewProvider {
//    static var previews: some View {
//        PersonalProfileView(userId: "fRo8nSNAUHSfdjDuXROCyVik8U83")
//    }
//}
