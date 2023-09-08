//
//  UserData.swift
//  Intent
//
//  Created by Nyaradzo Bere on 9/8/23.
//

import Foundation
import SwiftUI

class UserData: ObservableObject {
    @Published var userBio: String = ""
    @Published var userName: String = ""
    @Published var user: User? // Define a user property
    
    // You can add other properties as needed, such as user profile picture, email, etc.

    // You can also define methods to update and manage this data
    func updateUserBio(newBio: String) {
        userBio = newBio
        // You can add code here to update the user's bio in other places if needed
    }
}

