//
//  ListView.swift
//  Intent
//
//  Created by Nyaradzo Bere on 9/3/23.
//

import Foundation
import SwiftUI

struct ListView: View {
    let users: [User] = [/* Sample data here */]

    var body: some View {
        List(users) { user in
            NavigationLink(destination: ProfileView(user: user)) {
                Text(user.name)
            }
        }
    }
}

struct ListView_Previews: PreviewProvider {
    static var previews: some View {
        ListView()
    }
}
