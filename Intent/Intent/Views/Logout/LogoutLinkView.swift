//
//  LogoutLinkView.swift
//  Intent
//
//  Created by Nyaradzo Bere on 9/3/23.
//

import Foundation
import SwiftUI
import Firebase

struct LogoutLink: View {
    @State private var navigateToLoginView: Bool = false
    @State private var showAlert: Bool = false
    @State private var alertMessage: String = ""

    var body: some View {
        VStack {
            NavigationLink("", destination: LoginView(), isActive: $navigateToLoginView)
            Button("Logout") {
                logout()
            }
            .padding()
            .background(Color.black)
            .foregroundColor(.white)
            .cornerRadius(8)
        }
        .alert(isPresented: $showAlert) {
            Alert(title: Text("Error"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
        }
    }

    func logout() {
        do {
            try Auth.auth().signOut()
            navigateToLoginView = true
        } catch {
            alertMessage = "Error signing out. Please try again."
            showAlert = true
        }
    }
}

struct LogoutLink_Previews: PreviewProvider {
    static var previews: some View {
        LogoutLink()
    }
}
