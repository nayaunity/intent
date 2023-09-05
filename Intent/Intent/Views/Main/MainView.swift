//
//  MainView.swift
//  Intent
//
//  Created by Nyaradzo Bere on 9/5/23.
//

import Foundation
import SwiftUI
import FirebaseFirestore
import FirebaseAuth

struct MainView: View {
    @State private var hasProfile: Bool = false
    @State private var profileCheckCompleted: Bool = false  // New state variable

    var body: some View {
        VStack {
            if profileCheckCompleted {
                if hasProfile {
                    SwipeableView()
                } else {
                    CreateProfileView()
                }
            } else {
                // Display a neutral view while checking
                ProgressView()  // This is a loading spinner in SwiftUI
            }
        }
        .onAppear(perform: checkUserProfile)
    }

    func checkUserProfile() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let db = Firestore.firestore()
        let docRef = db.collection("users").document(uid)

        docRef.getDocument { (document, error) in
            if let document = document, document.exists {
                self.hasProfile = true
            } else {
                self.hasProfile = false
            }
            self.profileCheckCompleted = true  // Mark the check as completed
        }
    }
}
