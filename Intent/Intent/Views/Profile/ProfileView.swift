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

    var body: some View {
        ScrollView {
            VStack {
                WebImage(url: URL(string: user.profilePictureUrl))
                    .resizable()
                    .scaledToFit()
//                    .frame(width: 300, height: 400)
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
            }
        }
    }
}
