//
//  SwipeableView.swift
//  Intent
//
//  Created by Nyaradzo Bere on 9/3/23.
//

import Foundation
import SwiftUI

struct SwipeableView: View {
    @State private var offset: CGSize = .zero
    @State private var swipeStatus: SwipeStatus = .none
    @State private var currentIndex: Int = 0
    
    // Sample data - replace with your list of users or fetch them from your backend
    let users: [SwipeableUser] = [
        SwipeableUser(id: "1", name: "Alice", bio: "Bio goes here...", profileImage: "user1", rating: 4.5),
        SwipeableUser(id: "2", name: "Bob", bio: "Bio goes here...", profileImage: "user2", rating: 4.2),
        SwipeableUser(id: "3", name: "Taylor", bio: "Musician and weekend warrior.", profileImage: "user3", rating: 3.8),
        SwipeableUser(id: "4", name: "Casey", bio: "Tech enthusiast and traveler.", profileImage: "user4", rating: 4.7),
        SwipeableUser(id: "5", name: "Sam", bio: "Nature photographer.", profileImage: "user5", rating: 4.0),
        //... add more users
    ]

    var body: some View {
        ZStack {
            if currentIndex < users.count {
                CardView(user: users[currentIndex])
                    .offset(x: offset.width, y: offset.height)
                    .gesture(
                        DragGesture()
                            .onChanged { gesture in
                                self.offset = gesture.translation
                            }
                            .onEnded { _ in
                                if self.offset.width < -100 {
                                    self.swipeStatus = .left
                                } else if self.offset.width > 100 {
                                    self.swipeStatus = .right
                                } else {
                                    self.swipeStatus = .none
                                }
                                
                                switch self.swipeStatus {
                                case .none:
                                    self.offset = .zero
                                case .left, .right:
                                    self.currentIndex += 1
                                    self.offset = .zero
                                }
                            }
                    )
            } else {
                // Handle when there are no more cards
                Text("No more profiles")
            }
        }
    }
}

enum SwipeStatus {
    case left, right, none
}

struct CardView: View {
    var user: SwipeableUser

    var body: some View {
        VStack {
            Image(user.profileImage)
                .resizable()
                .scaledToFit()
                .frame(width: 400, height: 400)
                .clipped()
            Text(user.name)
            Text("Rating: \(user.rating, specifier: "%.1f")")
            Text(user.bio)
            // ... any other UI elements you want to display for the user
        }
        .frame(width: 300, height: 500)
        .background(Color.white)
        .cornerRadius(10)
        .shadow(radius: 10)
    }
}

struct SwipeableUser {
    var id: String
    var name: String
    var bio: String
    var profileImage: String
    var rating: Double
}

struct SwipeableView_Previews: PreviewProvider {
    static var previews: some View {
        SwipeableView()
    }
}
