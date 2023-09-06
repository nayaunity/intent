//
//  SwipeableView.swift
//  Intent
//
//  Created by Nyaradzo Bere on 9/3/23.
//

import SwiftUI
import FirebaseFirestore
import FirebaseAuth

struct SwipeableView: View {
    @State private var users: [User] = []
    @State private var offset: CGSize = .zero
    @State private var selectedGenders: Set<String> = ["Man", "Woman", "Non-binary"]
    @State private var showingFilterView: Bool = false
    @State private var swipedUserIDs: Set<String> = []
    @State private var showMatchesView: Bool = false
    @State private var showLoginView: Bool = false

    var body: some View {
        NavigationView {
            VStack {
                // Filter button
                Button(action: {
                    showingFilterView.toggle()
                }) {
                    Text("Filter")
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                .sheet(isPresented: $showingFilterView) {
                    FilterView(selectedGenders: $selectedGenders) {
                        // This block will be executed when filters are applied
                        fetchSwipedUsers()
                        fetchUsers()
                    }
                }
                
                Text("Selected genders: \(selectedGenders.sorted().joined(separator: ", "))")
                
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
                                        self.recordSwipe(for: self.users.first!.id!, liked: false)
                                        self.users.removeFirst()
                                    }
                                    self.offset = .zero
                                }
                        )
                } else {
                    Text("No more profiles to show!")
                }

                Spacer()

                // Button to navigate to MatchesView
                Button(action: {
                    self.showMatchesView = true
                }) {
                    Text("See Matches")
                        .padding()
                        .foregroundColor(.black)
                        .cornerRadius(8)
                }
                .padding(.bottom)
                
                NavigationLink("", destination: MatchesView(), isActive: $showMatchesView).hidden()
                NavigationLink("", destination: LoginView(), isActive: $showLoginView).hidden()
            }
            .onAppear {
                print("SwipeableView appeared")
                fetchSwipedUsers()
                fetchUsers()
            }
            .navigationBarItems(leading: logoutButton())
        }
    }

    func fetchUsers() {
        print("Fetching users based on filter: \(selectedGenders)")
        let db = Firestore.firestore()
        var query: Query = db.collection("users")
        
        if !selectedGenders.isEmpty {
            query = query.whereField("genderIdentity", in: Array(selectedGenders))
        }
        
        query.getDocuments { (snapshot, error) in
            guard let documents = snapshot?.documents else {
                print("No documents")
                return
            }
            
            let filteredUsers = documents.compactMap { (queryDocumentSnapshot) -> User? in
                let user = User(fromSnapshot: queryDocumentSnapshot)
                if let userId = user?.id,
                   userId != Auth.auth().currentUser?.uid,
                   !self.swipedUserIDs.contains(userId) {
                    return user
                }
                return nil
            }
            
            self.users = filteredUsers
            print("Fetched \(self.users.count) users after applying filter.")
        }
    }

    func fetchSwipedUsers() {
        print("Fetching swiped users")
        guard let currentUserID = Auth.auth().currentUser?.uid else { return }
        let db = Firestore.firestore()
        db.collection("swipes").document(currentUserID).getDocument { (document, error) in
            if let document = document, document.exists {
                let data = document.data()
                let likedUsers: [String] = data?["liked"] as? [String] ?? []
                let dislikedUsers: [String] = data?["disliked"] as? [String] ?? []
                self.swipedUserIDs = Set(likedUsers + dislikedUsers)
                print("Previously swiped user IDs: \(self.swipedUserIDs)")
            } else {
                print("Document does not exist or there was an error fetching it.")
            }
        }
    }

    func handleRightSwipe(on user: User) {
        print("Handling right swipe on user: \(user.id ?? "Unknown ID")")
        recordLike(for: user.id!) { success in
            if success {
                checkForMatch(with: user.id!) { matched in
                    if matched {
                        storeMatch(with: user.id!)
                    }
                }
            }
        }
    }

    func recordLike(for userID: String, completion: @escaping (Bool) -> Void) {
        print("Recording like for user: \(userID)")
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
                recordSwipe(for: userID, liked: true)
                completion(true)
            }
        }
    }

    func checkForMatch(with userID: String, completion: @escaping (Bool) -> Void) {
        print("Checking for match with user: \(userID)")
        let db = Firestore.firestore()
        guard let currentUserID = Auth.auth().currentUser?.uid else { return }

        db.collection("likes").whereField("liker", isEqualTo: userID).whereField("liked", isEqualTo: currentUserID).getDocuments { (snapshot, error) in
            if let error = error {
                print("Failed to check for match:", error)
                completion(false)
            } else if let documents = snapshot?.documents, !documents.isEmpty {
                print("It's a match!")
                completion(true)
            } else {
                completion(false)
            }
        }
    }

    func storeMatch(with userID: String) {
        print("Storing match with user: \(userID)")
        let db = Firestore.firestore()
        guard let currentUserID = Auth.auth().currentUser?.uid else { return }

        let matchData: [String: Any] = [
            "users": [currentUserID, userID]
        ]

        db.collection("matches").addDocument(data: matchData) { error in
            if let error = error {
                print("Failed to store match:", error)
            } else {
                print("Match stored successfully!")
            }
        }
    }

    func recordSwipe(for userID: String, liked: Bool) {
        let db = Firestore.firestore()
        guard let currentUserID = Auth.auth().currentUser?.uid else { return }

        db.collection("swipes").document(currentUserID).setData([
            liked ? "liked" : "disliked": FieldValue.arrayUnion([userID])
        ], merge: true) { error in
            if let error = error {
                print("Failed to record swipe:", error)
            } else {
                print("Swipe recorded successfully!")
            }
        }
    }

    func logoutButton() -> some View {
        Button(action: {
            do {
                try Auth.auth().signOut()
                print("Logged out successfully")
                self.showLoginView = true
            } catch let signOutError {
                print("Error signing out: \(signOutError.localizedDescription)")
            }
        }) {
            Text("Logout")
        }
    }
}

struct SwipeableView_Previews: PreviewProvider {
    static var previews: some View {
        SwipeableView()
    }
}
