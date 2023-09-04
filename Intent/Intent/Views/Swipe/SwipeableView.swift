//
//  SwipeableView.swift
//  Intent
//
//  Created by Nyaradzo Bere on 9/3/23.
//

import Foundation
import SwiftUI
import FirebaseFirestore
import FirebaseAuth

struct SwipeableView: View {
    @State private var users: [User] = []
    @State private var offset: CGSize = .zero
    @State private var isTextVisible: Bool = false  // Added this state

    var body: some View {
        VStack {
            if let user = users.first {
                CardView(user: user)
                    .offset(offset)
                    .gesture(
                        DragGesture()
                            .onChanged { gesture in
                                self.offset = gesture.translation
                            }
                            .onEnded { _ in
                                if self.offset.width < -100 {
                                    // Swipe left action
                                    self.users.removeFirst()
                                } else if self.offset.width > 100 {
                                    // Swipe right action
                                    self.users.removeFirst()
                                }
                                self.offset = .zero
                            }
                    )

                if isTextVisible {
                    Text("Animated text")
                }

            } else {
                Text("No more profiles to show!")
            }
        }
        .onAppear(perform: fetchUsers)
        .onAppear { // Add this block to animate the text on appear
            withAnimation(.spring()) {
                self.isTextVisible = true
            }
        }
    }

    func fetchUsers() {
        // Get the current user's ID
        guard let currentUserId = Auth.auth().currentUser?.uid else {
            print("Failed to get the current user's ID")
            return
        }
        
        print("Current User ID: \(currentUserId)")
        
        let db = Firestore.firestore()
        db.collection("users").getDocuments { (snapshot, error) in
            if let error = error {
                print("Error fetching users from Firestore: \(error.localizedDescription)")
                return
            }
            
            guard let documents = snapshot?.documents else {
                print("No documents returned from Firestore")
                return
            }

            print("Total users fetched from Firestore: \(documents.count)")
            
            self.users = documents.compactMap { (queryDocumentSnapshot) -> User? in
                // Convert the document to a User
                guard let user = User(fromSnapshot: queryDocumentSnapshot) else {
                    print("Failed to convert document to User: \(queryDocumentSnapshot.data())")
                    return nil
                }
                
                // Filter out the current user's profile
                if user.id == currentUserId {
                    print("Filtering out the current user's profile: \(user.name)")
                    return nil
                }
                
                return user
            }
            
            print("Total users after filtering out the current user: \(self.users.count)")
        }
    }
}

struct SwipeableView_Previews: PreviewProvider {
    static var previews: some View {
        SwipeableView()
    }
}

