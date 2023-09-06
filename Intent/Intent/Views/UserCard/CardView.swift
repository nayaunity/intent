//
//  CardView.swift
//  Intent
//
//  Created by Nyaradzo Bere on 9/4/23.
//

import Foundation
import SwiftUI
import SDWebImageSwiftUI

struct CardView: View {
    var user: User

    var body: some View {
        VStack {
            HStack {
                WebImage(url: URL(string: user.profilePictureUrl))
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 300, height: 400)
                    .clipped()
                    .cornerRadius(10)
            }
            
            VStack {
                Text(user.name)
                    .font(.title)
                    .padding(.top, 8)
                Text(user.bio)
                    .font(.subheadline)
                    .padding(.top, 4)
                    .foregroundColor(.gray)
            }
            .padding()
            .frame(width: 300)
            .background(Color.white)
            .cornerRadius(10)
            .shadow(radius: 1)
        }
    }
}

struct CardView_Previews: PreviewProvider {
    static var previews: some View {
        CardView(user: User(name: "John Doe"))
    }
}
