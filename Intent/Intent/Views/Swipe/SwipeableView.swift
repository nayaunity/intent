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
    let users: [User] = [
        User(id: "1", name: "Alice", bio: "Bio goes here..."),
        User(id: "2", name: "Bob", bio: "Bio goes here..."),
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
    var user: User

    var body: some View {
        VStack {
            Text(user.name)
            Text(user.bio)
            // ... any other UI elements you want to display for the user
        }
        .frame(width: 300, height: 400)
        .background(Color.white)
        .cornerRadius(10)
        .shadow(radius: 10)
    }
}

struct User {
    var id: String
    var name: String
    var bio: String
}

struct SwipeableView_Previews: PreviewProvider {
    static var previews: some View {
        SwipeableView()
    }
}
