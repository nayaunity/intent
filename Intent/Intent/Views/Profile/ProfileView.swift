//
//  ProfileView.swift
//  Intent
//
//  Created by Nyaradzo Bere on 9/3/23.
//

import Foundation
import SwiftUI
import FirebaseAuth
import FirebaseFirestore
import SDWebImageSwiftUI

struct ProfileView: View {
    var user: User

    @State private var isRatingViewPresented = false

    var body: some View {
        ScrollView {
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

                // ... Add more user details here if needed

                // "We went on a date" button
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
//                .sheet(isPresented: $isRatingViewPresented) {
//                    RatingView(ratedUser: user)
//                }
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
