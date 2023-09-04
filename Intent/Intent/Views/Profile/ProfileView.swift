//
//  ProfileView.swift
//  Intent
//
//  Created by Nyaradzo Bere on 9/3/23.
//

import Foundation
import SwiftUI

struct ProfileView: View {
    let user: User

    var body: some View {
        VStack {
            Text(user.name)
            Text(user.bio)
            Button("Provide Feedback", action: provideFeedback)
        }
    }

    func provideFeedback() {
        // Navigate to FeedbackView
    }
}

//struct ProfileView_Previews: PreviewProvider {
//    static var previews: some View {
//        ProfileView(user: User(id: "1", name: "Sample", bio: "Sample Bio", profileImageURL: "user1", rating: 4.2))
//    }
//}
