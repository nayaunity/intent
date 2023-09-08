//
//  EditProfileView.swift
//  Intent
//
//  Created by Nyaradzo Bere on 9/8/23.
//

import Foundation
import SwiftUI
import Firebase

struct EditProfileView: View {
    @Binding var isPresented: Bool
    @Binding var user: User? // Pass the user object that you want to edit
    @State private var editedBio: String // Add a state variable for edited bio

    init(isPresented: Binding<Bool>, user: Binding<User?>) {
        _isPresented = isPresented
        _user = user
        _editedBio = State(initialValue: user.wrappedValue?.bio ?? "")
    }

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Edit Bio")) {
                    TextField("Bio", text: $editedBio)
                }
            }
            .navigationBarTitle("Edit Profile")
            .navigationBarItems(
                leading: Button("Cancel") {
                    isPresented = false
                },
                trailing: Button("Save") {
                    // Call a function to update the user's bio
                    updateUserBio()
                }
            )
        }
    }

    // Function to update the user's bio in Firestore
    private func updateUserBio() {
        guard let uid = Auth.auth().currentUser?.uid else {
            return // User is not authenticated
        }
        
        // Reference to the Firestore database
        let db = Firestore.firestore()
        
        // Reference to the user document
        let userRef = db.collection("users").document(uid)
        
        // Update the bio field in Firestore with the edited bio
        userRef.updateData(["bio": editedBio]) { error in
            if let error = error {
                print("Error updating bio: \(error.localizedDescription)")
            } else {
                // Successfully updated bio
                // Update the user object with the edited bio
                user?.bio = editedBio
                isPresented = false
            }
        }
    }
}


//struct EditProfileView_Previews: PreviewProvider {
//    static var previews: some View {
//        EditProfileView(isPresented: Bool, bio: "Enthusiast")
//    }
//}
