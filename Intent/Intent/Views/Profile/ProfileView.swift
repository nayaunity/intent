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

struct ProfileView: View {
    @State private var user: User? = nil

    var body: some View {
        VStack {
            if let user = user {
                // Display user details
                Text(user.name)
                // ... other user details
            } else {
                Text("Loading profile...")
            }
        }
        .onAppear(perform: fetchUserProfile)
    }

    func fetchUserProfile() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let db = Firestore.firestore()
        let docRef = db.collection("users").document(uid)

        docRef.getDocument { (document, error) in
            if let document = document, document.exists, let data = try? document.data(as: User.self) {
                self.user = data
            } else {
                print("User profile not found")
            }
        }
    }
}

