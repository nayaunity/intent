//
//  SwipeableView.swift
//  Intent
//
//  Created by Nyaradzo Bere on 9/3/23.
//

import Foundation
import SwiftUI
import FirebaseFirestore

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
            print("Fetching users...") // Added for debugging
            
            let db = Firestore.firestore()
            db.collection("users").getDocuments { (snapshot, error) in
                if let error = error {
                    print("Error fetching users: \(error.localizedDescription)") // Added for debugging
                    return
                }
                
                guard let documents = snapshot?.documents else {
                    print("No documents or snapshot is nil.") // Added for debugging
                    return
                }

                print("Fetched \(documents.count) users.") // Added for debugging
                
                self.users = documents.compactMap { (queryDocumentSnapshot) -> User? in
                    let user = User(fromSnapshot: queryDocumentSnapshot)
                    if user == nil {
                        print("Failed to parse user from document: \(queryDocumentSnapshot.data())") // Added for debugging
                    }
                    return user
                }
            }
        }
}

struct SwipeableView_Previews: PreviewProvider {
    static var previews: some View {
        SwipeableView()
    }
}

