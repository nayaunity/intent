//
//  CreateProfileView.swift
//  Intent
//
//  Created by Nyaradzo Bere on 9/3/23.
//

import Foundation
import SwiftUI
import Firebase
import FirebaseFirestore

struct CreateProfileView: View {
    @State private var name: String = ""
    @State private var sex: String = ""
    @State private var genderIdentity: String = ""
    @State private var bio: String = ""
    @State private var profilePicture: UIImage? = nil  // Placeholder for image upload logic
    
    @State private var showAlert: Bool = false
    @State private var alertMessage: String = ""
    @State private var navigateToSwipeView: Bool = false

    private let neutralColor = Color.gray.opacity(0.2)
    private let fontDesign = Font.system(size: 18, weight: .thin)

    var body: some View {
        NavigationView {
            VStack(alignment: .leading, spacing: 25) {
                TextField("Name", text: $name)
                    .padding()
                    .background(neutralColor)
                    .cornerRadius(10)
                    .font(fontDesign)

                HStack(spacing: 30) {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Sex:")
                            .font(fontDesign)
                        Picker("Select Sex", selection: $sex) {
                            Text("Select...").tag("")
                            Text("Male").tag("Male")
                            Text("Female").tag("Female")
                        }
                        .padding()
                        .background(neutralColor)
                        .cornerRadius(10)
                    }

                    VStack(alignment: .leading, spacing: 10) {
                        Text("Gender Identity:")
                            .font(fontDesign)
                        Picker("Select Gender Identity", selection: $genderIdentity) {
                            Text("Select...").tag("")
                            Text("Man").tag("Man")
                            Text("Woman").tag("Woman")
                            Text("Non-binary").tag("Non-binary")
                        }
                        .padding()
                        .background(neutralColor)
                        .cornerRadius(10)
                    }
                }

                TextField("Bio", text: $bio)
                    .padding()
                    .background(neutralColor)
                    .cornerRadius(10)
                    .font(fontDesign)

                Button("Save Profile", action: saveProfile)
                    .padding(.vertical, 10)
                    .padding(.horizontal, 30)
                    .background(Color.black)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    .font(fontDesign)

                Button("Go to Swipe View") {
                    navigateToSwipeView = true
                }
                .padding(.vertical, 10)
                .padding(.horizontal, 30)
                .background(Color.gray)
                .foregroundColor(.black)
                .cornerRadius(10)
                .font(fontDesign)
            }
            .padding(.horizontal, 30)
            .padding(.vertical, 20)
            .alert(isPresented: $showAlert) {
                Alert(title: Text("Error"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
            }
            .background(NavigationLink("", destination: SwipeableView(), isActive: $navigateToSwipeView))
//            .navigationTitle("Create Profile")
            .navigationBarItems(trailing: LogoutLink())
            .background(Color.white.edgesIgnoringSafeArea(.all))
        }
    }

    func allFieldsValid() -> Bool {
        return !name.isEmpty && !sex.isEmpty && !genderIdentity.isEmpty && !bio.isEmpty
    }

    func saveProfile() {
        if !allFieldsValid() {
            alertMessage = "Please fill out all fields before saving."
            showAlert = true
            return
        }

        guard let uid = Auth.auth().currentUser?.uid else { return }
        guard let email = Auth.auth().currentUser?.email else { return }

        let db = Firestore.firestore()
        let docRef = db.collection("users").document(uid)

        let values: [String: Any] = [
            "email": email,
            "name": name,
            "sex": sex,
            "genderIdentity": genderIdentity,
            "bio": bio
            // Handle profile picture uploads and save URL/reference here
        ]

        docRef.setData(values) { error in
            if let error = error {
                print("Error writing document: \(error)")
                alertMessage = "Error saving profile. Please try again."
                showAlert = true
            } else {
                print("Document successfully written!")
                // Handle what to do next, e.g. navigate to the main app
            }
        }
    }
}

struct CreateProfileView_Previews: PreviewProvider {
    static var previews: some View {
        CreateProfileView()
    }
}
