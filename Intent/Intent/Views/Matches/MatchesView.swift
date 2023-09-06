//
//  MatchesView.swift
//  Intent
//
//  Created by Nyaradzo Bere on 9/4/23.
//

import SwiftUI
import Firebase
import SDWebImageSwiftUI

struct MatchesView: View {
    @State private var matchedUsers: [User]

    init(matchedUsers: [User] = []) {
        _matchedUsers = State(initialValue: matchedUsers)
    }

    var body: some View {
        VStack {
            Text("Your Matches")
                .font(.largeTitle)
                .padding()

            List(matchedUsers) { user in
                HStack {
                    NavigationLink(destination: ProfileView(user: user)) {
                        WebImage(url: URL(string: user.profilePictureUrl))
                            .resizable()
                            .scaledToFit()
//                            .frame(width: 60, height: 60)
                            .clipShape(Circle())
                            .frame(width: 60, height: 60)
                            .overlay(Circle().stroke(Color.white, lineWidth: 2))
                    }
                    Text(user.name)
                }
            }
        }
        .onAppear(perform: fetchMatches)
    }

    func fetchMatches() {
        guard let currentUserId = Auth.auth().currentUser?.uid else {
            print("User is not signed in.")
            return
        }

        print("Fetching matches for user \(currentUserId)")

        let db = Firestore.firestore()
        let likesRef = db.collection("likes")

        // Fetch users that the current user has liked
        likesRef.whereField("liker", isEqualTo: currentUserId).getDocuments { snapshot, error in
            guard let documents = snapshot?.documents else {
                print("Error fetching liked users: \(error?.localizedDescription ?? "Unknown error")")
                return
            }

            let likedUserIds = documents.compactMap { $0["liked"] as? String }

            // Fetch users that have liked the current user
            likesRef.whereField("liked", isEqualTo: currentUserId).getDocuments { snapshot, error in
                guard let documents = snapshot?.documents else {
                    print("Error fetching users who liked the current user: \(error?.localizedDescription ?? "Unknown error")")
                    return
                }

                let usersWhoLikedCurrentUser = documents.compactMap { $0["liker"] as? String }

                // Find mutual likes to determine matches
                let mutualLikes = Set(likedUserIds).intersection(usersWhoLikedCurrentUser)

                // Fetch details of matched users
                let usersRef = db.collection("users")
                if !mutualLikes.isEmpty {
                    usersRef.whereField(FieldPath.documentID(), in: Array(mutualLikes)).getDocuments { snapshot, error in
                        guard let documents = snapshot?.documents else {
                            print("Error fetching matched user details: \(error?.localizedDescription ?? "Unknown error")")
                            return
                        }

                        self.matchedUsers = documents.compactMap { User(fromSnapshot: $0) }
                    }
                }
            }
        }
    }
}

struct MatchesView_Previews: PreviewProvider {
    static var previews: some View {
        MatchesView(matchedUsers: User.mocks)
    }
}

extension User {
    static var mock: User {
        User(id: "1", name: "Alex", bio: "Friendly and outgoing", email: "alex@example.com", sex: "Male", genderIdentity: "Man", profilePictureUrl: "https://images.unsplash.com/photo-1567532939604-b6b5b0db2604?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=2787&q=80", rating: 4.5)
    }

    static var mocks: [User] {
        [
            User.mock,
            User(id: "2", name: "Jamie", bio: "Adventure lover", email: "jamie@example.com", sex: "Female", genderIdentity: "Woman", profilePictureUrl: "https://images.unsplash.com/photo-1664575602554-2087b04935a5?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=2787&q=80", rating: 5.0)
        ]
    }
}
