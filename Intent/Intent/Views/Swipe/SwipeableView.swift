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
    @State private var isTextVisible: Bool = false
    @State private var selectedGender: String? = nil
    @State private var showingFilterSheet: Bool = false

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
                                if self.offset.width > 100 {
                                    self.handleRightSwipe(on: self.users.first!)
                                    self.users.removeFirst()
                                } else if self.offset.width < -100 {
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
        .navigationBarItems(trailing:
            Button(action: {
                showingFilterSheet = true
            }) {
                Label("Filter", systemImage: "slider.horizontal.3")
            }
            .actionSheet(isPresented: $showingFilterSheet) {
                ActionSheet(title: Text("Select Gender"), buttons: [
                    .default(Text("All")) { updateFilter(to: nil) },
                    .default(Text("Man")) { updateFilter(to: "Man") },
                    .default(Text("Woman")) { updateFilter(to: "Woman") },
                    .default(Text("Non-binary")) { updateFilter(to: "Non-binary") },
                    .cancel()
                ])
            }
        )
        .onAppear(perform: fetchUsers)
        .onAppear {
            withAnimation(.spring()) {
                self.isTextVisible = true
            }
        }
    }

    func updateFilter(to gender: String?) {
        print("Filter updated to: \(gender ?? "All")")
        selectedGender = gender
        fetchUsers()
    }

    func fetchUsers() {
        print("Fetching users based on filter: \(selectedGender ?? "All")")
        let db = Firestore.firestore()
        var query: Query = db.collection("users")
        if let gender = selectedGender {
            query = query.whereField("genderIdentity", isEqualTo: gender)
        }
        query.getDocuments { (snapshot, error) in
            guard let documents = snapshot?.documents else {
                print("No documents")
                return
            }

            self.users = documents.compactMap { (queryDocumentSnapshot) -> User? in
                let user = User(fromSnapshot: queryDocumentSnapshot)
                // Excluding the currently logged-in user from the users list
                return (user?.id != Auth.auth().currentUser?.uid) ? user : nil
            }
            print("Fetched \(self.users.count) users after applying filter.")
        }
    }

    func handleRightSwipe(on user: User) {
        // Record the like
        recordLike(for: user.id!) { success in
            if success {
                // Check for a match
                checkForMatch(with: user.id!) { matched in
                    if matched {
                        // Store the match
                        storeMatch(with: user.id!)
                    }
                }
            }
        }
    }

    func recordLike(for userID: String, completion: @escaping (Bool) -> Void) {
        let db = Firestore.firestore()
        guard let currentUserID = Auth.auth().currentUser?.uid else { return }

        let likeData: [String: Any] = [
            "liker": currentUserID,
            "liked": userID
        ]

        db.collection("likes").addDocument(data: likeData) { error in
            if let error = error {
                print("Failed to record like:", error)
                completion(false)
            } else {
                completion(true)
            }
        }
    }

    func checkForMatch(with userID: String, completion: @escaping (Bool) -> Void) {
        let db = Firestore.firestore()
        guard let currentUserID = Auth.auth().currentUser?.uid else { return }

        db.collection("likes").whereField("liker", isEqualTo: userID).whereField("liked", isEqualTo: currentUserID).getDocuments { (snapshot, error) in
            if let error = error {
                print("Error checking for match:", error)
                completion(false)
            } else if let documents = snapshot?.documents, !documents.isEmpty {
                completion(true)
            } else {
                completion(false)
            }
        }
    }

    func storeMatch(with userID: String) {
        let db = Firestore.firestore()
        guard let currentUserID = Auth.auth().currentUser?.uid else { return }

        let matchData: [String: Any] = [
            "user1": currentUserID,
            "user2": userID,
            "timestamp": FieldValue.serverTimestamp()
        ]

        db.collection("matches").addDocument(data: matchData) { error in
            if let error = error {
                print("Failed to store match:", error)
            } else {
                print("Match stored successfully!")
            }
        }
    }
}

struct SwipeableView_Previews: PreviewProvider {
    static var previews: some View {
        SwipeableView()
    }
}
