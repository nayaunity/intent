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
            WebImage(url: URL(string: user.profilePictureUrl))
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 300, height: 400)
                .clipped()
                .cornerRadius(10)
            
            Text(user.name)
                .font(.title)
                .padding(.top, 8)
            
            Text(user.bio)
                .font(.subheadline)
                .padding(.top, 4)
                .foregroundColor(.gray)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(10)
        .shadow(radius: 5)
    }
}
