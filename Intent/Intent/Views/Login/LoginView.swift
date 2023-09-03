//
//  LoginView.swift
//  Intent
//
//  Created by Nyaradzo Bere on 9/3/23.
//

import Foundation
import SwiftUI

struct LoginView: View {
    @State private var username: String = ""
    @State private var password: String = ""

    var body: some View {
        VStack(alignment: .center, spacing: 20) {
            TextField("Username", text: $username)
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(8)
                .autocapitalization(.none)

            SecureField("Password", text: $password)
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(8)

            Button("Login", action: login)
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(8)

            Button("Sign Up", action: signUp)
                .padding()
                .background(Color.green)
                .foregroundColor(.white)
                .cornerRadius(8)
        }
        .padding(.horizontal, 40)
    }

    func login() {
        // Handle login logic
    }

    func signUp() {
        // Handle sign-up logic
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
    }
}
