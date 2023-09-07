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

    var body: some View {
        VStack {
            if let user = user {
                WebImage(url: URL(string: user.profilePictureUrl))
                    .resizable()
                    .scaledToFit()
                    .clipShape(Circle())
                    .frame(width: 150, height: 150)
                    .overlay(Circle().stroke(Color.white, lineWidth: 2))
                    .padding()

                Text(user.name)
                    .font(.title)
                    .padding(.bottom)

                Text("Email: \(user.email)")
                    .padding(.bottom)

                Text(user.bio)
                    .font(.body)
                    .multilineTextAlignment(.center)
                    .padding()

                Text("Sex: \(user.sex)")
                    .padding(.bottom)

                Text("Gender Identity: \(user.genderIdentity)")
                    .padding(.bottom)

                if let rating = user.rating {
                    Text("Rating: \(rating, specifier: "%.1f")")
                        .padding(.bottom)
                }
            } else {
                Text("Loading profile...")
            }
        }
        .padding()
        .onAppear(perform: loadUserProfile)
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
}

struct PersonalProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView(user: mockUser())
    }
    
    static func mockUser() -> User {
        return User(id: "mockUserId", name: "Alex", bio: "Friendly and outgoing", email: "alex@example.com", sex: "Male", genderIdentity: "Man", profilePictureUrl: "https://images.unsplash.com/photo-1567532939604-b6b5b0db2604?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=2787&q=80", rating: 4.5)
    }
}
